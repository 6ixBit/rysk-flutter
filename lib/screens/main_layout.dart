import 'package:flutter/material.dart';
import '../components/bottom_nav.dart';
import 'home/home_screen.dart';
import 'documents/documents_screen.dart';
import 'knowledge/knowledge_screen.dart';
import 'scanner/document_scanner_screen.dart';
import 'document/document_viewer_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../services/supabase_document_service.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final SupabaseDocumentService _supabaseService = SupabaseDocumentService();
  bool _busy = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DocumentsScreen(),
    const KnowledgeScreen(),
  ];

  void _onNavTap(int index) {
    // If switching to documents tab, trigger a refresh
    if (index == 1 && _currentIndex != 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Force a rebuild of the documents screen
        setState(() {
          _currentIndex = index;
        });
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _openQuickAdd() async {
    if (_busy) return;
    showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  title: Text(
                    'Scan Document',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Use your camera to capture pages',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handleScan();
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  title: Text(
                    'Upload File',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Choose from Photos or Files',
                    style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _handleUpload();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleScan() async {
    if (!mounted || _busy) return;
    setState(() => _busy = true);
    try {
      final List<File>? scanned = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentScannerScreen()),
      );
      if (scanned == null || scanned.isEmpty) return;

      final docId = await _supabaseService.createDocument(
        title:
            'Scanned ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        pageCount: scanned.length,
      );
      await _supabaseService.uploadImagesAndInsert(
        documentId: docId,
        files: scanned,
      );
      final doc = await _supabaseService.getDocumentById(docId);
      if (!mounted) return;
      if (doc != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerScreen(document: doc),
          ),
        );
      }
    } catch (e) {
      // Optional: show error snackbar
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _handleUpload() async {
    if (!mounted || _busy) return;
    setState(() => _busy = true);
    try {
      // Let user choose Photos or Files
      final source = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF3B82F6),
                  ),
                  title: const Text('Photo Library'),
                  onTap: () => Navigator.pop(context, 'photos'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.folder_outlined,
                    color: Color(0xFF10B981),
                  ),
                  title: const Text('Files'),
                  onTap: () => Navigator.pop(context, 'files'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
      if (source == null) return;

      File? picked;
      if (source == 'photos') {
        final XFile? x = await _picker.pickImage(source: ImageSource.gallery);
        if (x != null) picked = File(x.path);
      } else if (source == 'files') {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          picked = File(result.files.first.path!);
        }
      }
      if (picked == null) return;

      final docId = await _supabaseService.createDocument(
        title: path.basename(picked.path),
        pageCount: 1,
        fileSizeBytes: await picked.length(),
      );
      await _supabaseService.uploadImagesAndInsert(
        documentId: docId,
        files: [picked],
      );
      final doc = await _supabaseService.getDocumentById(docId);
      if (!mounted) return;
      if (doc != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentViewerScreen(document: doc),
          ),
        );
      }
    } catch (e) {
      // Optional: show error snackbar
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _screens[0], // Home
          _currentIndex == 1
              ? DocumentsScreen(
                  key: ValueKey(
                    'docs_${DateTime.now().millisecondsSinceEpoch}',
                  ),
                )
              : _screens[1], // Documents - recreate when selected
          _screens[2], // Knowledge
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      floatingActionButton: Padding(
        // Position just a few pixels above the ~70px bottom nav
        padding: const EdgeInsets.only(bottom: 3.0, right: 0.0),
        child: GestureDetector(
          onTap: _openQuickAdd,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
