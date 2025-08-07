import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../scanner/document_scanner_screen.dart';
import '../document/document_viewer_screen.dart';
import '../../models/document.dart';
import '../../services/local_document_service.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final LocalDocumentService _documentService = LocalDocumentService();

  Future<void> _scanDocument() async {
    try {
      final List<File>? scannedDocuments = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentScannerScreen()),
      );

      if (scannedDocuments != null && scannedDocuments.isNotEmpty) {
        _documentService.addMultipleDocuments(scannedDocuments);
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      _showErrorDialog('Failed to scan document');
    }
  }

  Future<void> _uploadDocument() async {
    try {
      // Show action sheet to let user choose source
      final result = await showModalBottomSheet<String>(
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
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Choose Source',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 24),

                // Photo Library Option
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Color(0xFF3B82F6),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Photo Library',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    'Choose from your photos',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, 'photos'),
                ),

                // Files Option
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    'Files',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Text(
                    'Browse documents and files',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  onTap: () => Navigator.pop(context, 'files'),
                ),

                const SizedBox(height: 16),

                // Cancel Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );

      if (result == null) return;

      File? document;

      if (result == 'photos') {
        // Use photo library
        final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (file != null) {
          document = File(file.path);
        }
      } else if (result == 'files') {
        // Use file picker for documents
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          document = File(result.files.first.path!);
        }
      }

      if (document != null) {
        _documentService.addDocument(document);
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      _showErrorDialog('Failed to upload document');
    }
  }

  void _viewDocument(Document document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: document),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = _documentService.documents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rysk',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.person, color: Color(0xFF6B7280)),
              onPressed: () {
                // TODO: Navigate to profile
              },
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.camera_alt,
                    title: 'Scan Document',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: _scanDocument,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.upload_file,
                    title: 'Upload File',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: _uploadDocument,
                  ),
                ),
              ],
            ),
          ),

          // Recent Files Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 32.0, 16.0, 0.0),
            child: Text(
              'Recent Files',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent Documents
          Expanded(
            child: documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            size: 40,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No documents yet',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by scanning or uploading a document',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final document = documents[index];
                      return _DocumentCard(
                        document: document,
                        onTap: () => _viewDocument(document),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Gradient gradient;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Increased height by 10px
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;

  const _DocumentCard({required this.document, required this.onTap});

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Document thumbnail
                Container(
                  width: 60,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: document.images.isNotEmpty
                        ? Image.file(document.images.first, fit: BoxFit.cover)
                        : const Icon(
                            Icons.description,
                            color: Color(0xFF6B7280),
                          ),
                  ),
                ),
                const SizedBox(width: 16),

                // Document details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document.images.length} page${document.images.length == 1 ? '' : 's'}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document.uploadDate.day}/${document.uploadDate.month}/${document.uploadDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Risk score
                      if (document.analysis != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRiskColor(
                              document.analysis!.riskLevel,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getRiskColor(
                                document.analysis!.riskLevel,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${document.analysis!.riskLevel.substring(0, 1).toUpperCase()}${document.analysis!.riskLevel.substring(1).toLowerCase()} Risk',
                            style: GoogleFonts.inter(
                              color: _getRiskColor(
                                document.analysis!.riskLevel,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
