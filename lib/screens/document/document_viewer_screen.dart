import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/document.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Document document;

  const DocumentViewerScreen({super.key, required this.document});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _imagePageController.dispose();
    super.dispose();
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

  Color _getClauseRiskColor(int riskLevel) {
    if (riskLevel <= 3) return Colors.green;
    if (riskLevel <= 6) return Colors.orange;
    if (riskLevel <= 8) return Colors.red;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.document.status != DocumentStatus.completed ||
        widget.document.analysis == null) {
      return _buildProcessingScreen();
    }

    final analysis = widget.document.analysis!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.document.title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
            Tab(icon: Icon(Icons.warning), text: 'Risk Clauses'),
            Tab(icon: Icon(Icons.image), text: 'Document'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAnalysisTab(analysis),
          _buildRiskClausesTab(analysis),
          _buildDocumentTab(),
        ],
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.document.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _getStatusDescription(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (widget.document.status) {
      case DocumentStatus.uploading:
        return 'Uploading...';
      case DocumentStatus.processing:
        return 'Analyzing Document...';
      case DocumentStatus.failed:
        return 'Analysis Failed';
      default:
        return 'Processing...';
    }
  }

  String _getStatusDescription() {
    switch (widget.document.status) {
      case DocumentStatus.uploading:
        return 'Securely uploading your document';
      case DocumentStatus.processing:
        return 'AI is analyzing the document for risks and extracting key clauses';
      case DocumentStatus.failed:
        return widget.document.errorMessage ?? 'Something went wrong';
      default:
        return 'Please wait...';
    }
  }

  Widget _buildAnalysisTab(DocumentAnalysis analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Risk Score Card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Overall Risk Score',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: analysis.overallRiskScore / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getRiskColor(analysis.riskLevel),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            analysis.overallRiskScore.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getRiskColor(analysis.riskLevel),
                            ),
                          ),
                          Text(
                            analysis.riskLevel,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _getRiskColor(analysis.riskLevel),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getRiskDescription(analysis.riskLevel),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Risk Clauses',
                  analysis.topRiskyClauses.length.toString(),
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pages',
                  analysis.metadata['pageCount']?.toString() ?? '0',
                  Icons.description,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Document Info
          Text(
            'Document Details',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Type',
                    analysis.metadata['documentType'] ?? 'Unknown',
                  ),
                  _buildDetailRow(
                    'Upload Date',
                    _formatDate(widget.document.uploadDate),
                  ),
                  _buildDetailRow(
                    'Processing Time',
                    analysis.metadata['processingTime'] ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Confidence',
                    '${((analysis.metadata['confidence'] ?? 0.0) * 100).toInt()}%',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskClausesTab(DocumentAnalysis analysis) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: analysis.topRiskyClauses.length,
      itemBuilder: (context, index) {
        final clause = analysis.topRiskyClauses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getClauseRiskColor(clause.riskLevel),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  clause.riskLevel.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              clause.title,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(clause.description),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clause Text:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        clause.clause,
                        style: GoogleFonts.inter(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Why This is Risky:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(clause.explanation),
                    const SizedBox(height: 16),
                    Text(
                      'Recommendations:',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...clause.recommendations.map(
                      (rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• '),
                            Expanded(child: Text(rec)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocumentTab() {
    return Column(
      children: [
        // Image navigation
        if (widget.document.images.length > 1)
          Container(
            height: 60,
            padding: const EdgeInsets.all(8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.document.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _imagePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentImageIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.file(
                        widget.document.images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Main image view
        Expanded(
          child: PageView.builder(
            controller: _imagePageController,
            itemCount: widget.document.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      widget.document.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Page indicator
        if (widget.document.images.length > 1)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Page ${_currentImageIndex + 1} of ${widget.document.images.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _getRiskDescription(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return 'This document has minimal risk factors. Most terms appear standard and favorable.';
      case 'medium':
        return 'This document has some concerning clauses that warrant attention before signing.';
      case 'high':
        return 'This document contains several high-risk clauses that require careful review and negotiation.';
      case 'critical':
        return 'This document has critical risk factors. We strongly recommend legal review before proceeding.';
      default:
        return 'Risk assessment completed.';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
