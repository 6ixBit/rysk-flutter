import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../scanner/document_scanner_screen.dart';
import '../document/document_viewer_screen.dart';
import '../../models/document.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _documents = [];

  Future<void> _scanDocument() async {
    try {
      final List<File>? scannedDocuments = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DocumentScannerScreen()),
      );

      if (scannedDocuments != null && scannedDocuments.isNotEmpty) {
        setState(() {
          _documents.addAll(scannedDocuments);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to scan document');
    }
  }

  Future<void> _uploadDocument() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

      if (file != null) {
        final File document = File(file.path);
        setState(() {
          _documents.add(document);
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to upload document');
    }
  }

  void _viewDocument(File documentFile) {
    // Create a dummy document with analysis for viewing
    final dummyDocument = Document(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title:
          'Document ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      images: [documentFile],
      uploadDate: DateTime.now(),
      status: DocumentStatus.completed,
      analysis: _createDummyAnalysis(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(document: dummyDocument),
      ),
    );
  }

  DocumentAnalysis _createDummyAnalysis() {
    return DocumentAnalysis(
      overallRiskScore: 67.0,
      riskLevel: 'Medium',
      topRiskyClauses: [
        RiskyClause(
          id: 'clause_1',
          title: 'Unlimited Liability',
          description:
              'This clause exposes you to unlimited financial liability',
          clause:
              'Party A shall be liable for any and all damages, costs, and expenses arising from or related to this agreement, without limitation.',
          riskLevel: 9,
          explanation:
              'This clause removes all caps on your potential liability, meaning you could be responsible for unlimited damages.',
          recommendations: [
            'Negotiate a liability cap',
            'Add specific exceptions',
            'Consider insurance requirements',
          ],
        ),
        RiskyClause(
          id: 'clause_2',
          title: 'Broad Indemnification',
          description: 'Excessive indemnification requirements',
          clause:
              'Party A agrees to indemnify and hold harmless Party B from any claims, damages, or losses.',
          riskLevel: 7,
          explanation:
              'This broad indemnification clause could make you responsible for the other party\'s own negligence.',
          recommendations: [
            'Limit indemnification scope',
            'Add mutual indemnification',
            'Exclude gross negligence',
          ],
        ),
      ],
      extractedText: '''
PROFESSIONAL SERVICES AGREEMENT

This Professional Services Agreement ("Agreement") is entered into on [Date] between [Company A] and [Company B].

1. SCOPE OF WORK
The Contractor agrees to provide professional consulting services as detailed in Exhibit A.

2. COMPENSATION
Client shall pay Contractor a total fee of \$50,000 for the services described herein.

3. LIABILITY
Party A shall be liable for any and all damages, costs, and expenses arising from or related to this agreement, without limitation.

4. INDEMNIFICATION
Party A agrees to indemnify and hold harmless Party B from any claims, damages, or losses.
      ''',
      metadata: {
        'documentType': 'Professional Services Agreement',
        'pageCount': 1,
        'processingTime': '2.1 seconds',
        'confidence': 0.89,
      },
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rysk',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, // Bold Inter font
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // TODO: Navigate to profile
              },
            ),
          ),
        ],
      ),
      body: Column(
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
                    onTap: _scanDocument,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.upload_file,
                    title: 'Upload Document',
                    onTap: _uploadDocument,
                  ),
                ),
              ],
            ),
          ),

          // Recent Documents
          Expanded(
            child: _documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.description,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No documents yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by scanning or uploading a document',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final document = _documents[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(document, fit: BoxFit.cover),
                            ),
                          ),
                          title: Text(
                            path.basename(document.path),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Added ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Ready to view',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _viewDocument(document),
                        ),
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

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
