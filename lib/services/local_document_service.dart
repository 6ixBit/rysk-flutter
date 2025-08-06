import 'dart:io';
import '../models/document.dart';

class LocalDocumentService {
  static final LocalDocumentService _instance =
      LocalDocumentService._internal();
  factory LocalDocumentService() => _instance;
  LocalDocumentService._internal();

  final List<Document> _documents = [];

  List<Document> get documents {
    print(
      '📋 LocalDocumentService: Getting documents - count: ${_documents.length}',
    );
    return List.unmodifiable(_documents);
  }

  void addDocument(File imageFile) {
    final document = Document(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      title:
          'Document ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
      images: [imageFile],
      uploadDate: DateTime.now(),
      status: DocumentStatus.completed,
      analysis: _createDummyAnalysis(),
    );

    _documents.insert(0, document); // Add to beginning of list
    print(
      '📋 LocalDocumentService: Added document - total count: ${_documents.length}',
    );
  }

  void addMultipleDocuments(List<File> imageFiles) {
    for (final file in imageFiles) {
      addDocument(file);
    }
  }

  Document? getDocument(String id) {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  void removeDocument(String id) {
    _documents.removeWhere((doc) => doc.id == id);
  }

  void clearAll() {
    _documents.clear();
  }

  // TODO: Replace this with actual Supabase call
  DocumentAnalysis _createDummyAnalysis() {
    final riskScores = [45.0, 67.0, 78.0, 23.0, 89.0];
    final riskLevels = ['Low', 'Medium', 'High', 'Low', 'Critical'];
    final randomIndex = DateTime.now().millisecond % riskScores.length;

    return DocumentAnalysis(
      overallRiskScore: riskScores[randomIndex],
      riskLevel: riskLevels[randomIndex],
      topRiskyClauses: _getRandomRiskyClauses(),
      extractedText:
          '''
PROFESSIONAL SERVICES AGREEMENT

This Professional Services Agreement ("Agreement") is entered into on [Date] between [Company A] and [Company B].

1. SCOPE OF WORK
The Contractor agrees to provide professional consulting services as detailed in Exhibit A.

2. COMPENSATION
Client shall pay Contractor a total fee of \$${(25000 + (DateTime.now().millisecond * 100))} for the services described herein.

3. LIABILITY
Party A shall be liable for any and all damages, costs, and expenses arising from or related to this agreement, without limitation.

4. INDEMNIFICATION
Party A agrees to indemnify and hold harmless Party B from any claims, damages, or losses.
      ''',
      metadata: {
        'documentType': 'Professional Services Agreement',
        'pageCount': 1,
        'processingTime':
            '${(1.5 + (DateTime.now().millisecond % 10) / 10).toStringAsFixed(1)} seconds',
        'confidence': 0.85 + (DateTime.now().millisecond % 15) / 100,
      },
    );
  }

  List<RiskyClause> _getRandomRiskyClauses() {
    final allClauses = [
      RiskyClause(
        id: 'clause_1',
        title: 'Unlimited Liability',
        description: 'This clause exposes you to unlimited financial liability',
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
      RiskyClause(
        id: 'clause_3',
        title: 'Automatic Renewal',
        description: 'Contract renews automatically without notice',
        clause:
            'This agreement shall automatically renew for successive one-year periods unless terminated.',
        riskLevel: 5,
        explanation:
            'Automatic renewal clauses can lock you into unfavorable terms if you forget to cancel.',
        recommendations: [
          'Add termination notice requirements',
          'Negotiate shorter renewal periods',
          'Include right to renegotiate terms',
        ],
      ),
      RiskyClause(
        id: 'clause_4',
        title: 'IP Assignment',
        description: 'Broad intellectual property transfer',
        clause:
            'All work product and intellectual property created shall belong exclusively to Party B.',
        riskLevel: 8,
        explanation:
            'This clause transfers valuable intellectual property rights that could be worth significant future value.',
        recommendations: [
          'Retain rights to pre-existing IP',
          'Negotiate shared ownership',
          'Add carve-outs for general knowledge',
        ],
      ),
    ];

    // Return 2-3 random clauses
    final shuffled = List<RiskyClause>.from(allClauses)..shuffle();
    return shuffled.take(2 + (DateTime.now().millisecond % 2)).toList();
  }
}
