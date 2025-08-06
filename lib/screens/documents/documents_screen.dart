import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/document.dart';
import '../../services/local_document_service.dart';
import '../document/document_viewer_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  final LocalDocumentService _documentService = LocalDocumentService();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh when the screen is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  // Add a manual refresh method
  void refresh() {
    if (mounted) {
      setState(() {});
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
    super.build(context);
    final documents = _documentService.documents;

    print('📱 Documents screen building with ${documents.length} documents');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Documents'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No documents yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Documents you scan or upload will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75, // Reduced to make cards taller
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return _DocumentGridCard(
                    document: document,
                    onTap: () => _viewDocument(document),
                    getRiskColor: _getRiskColor,
                  );
                },
              ),
            ),
    );
  }
}

class _DocumentGridCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final Color Function(String) getRiskColor;

  const _DocumentGridCard({
    required this.document,
    required this.onTap,
    required this.getRiskColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Document thumbnail
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: document.images.isNotEmpty
                        ? Image.file(document.images.first, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF9FAFB),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 48,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                  ),
                ),
              ),

              // Document info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        document.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Date
                      Text(
                        '${document.uploadDate.day}/${document.uploadDate.month}/${document.uploadDate.year}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),

                      const Spacer(),

                      // Bottom row: Risk badge (left) and Page count (right)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Risk badge (bottom left)
                          if (document.analysis != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: getRiskColor(
                                  document.analysis!.riskLevel,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: getRiskColor(
                                    document.analysis!.riskLevel,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${document.analysis!.riskLevel.substring(0, 1).toUpperCase()}${document.analysis!.riskLevel.substring(1).toLowerCase()} Risk',
                                style: GoogleFonts.inter(
                                  color: getRiskColor(
                                    document.analysis!.riskLevel,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // Page count (bottom right)
                          Text(
                            '${document.images.length} page${document.images.length == 1 ? '' : 's'}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
