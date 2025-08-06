import 'dart:io';
import 'dart:convert';
import 'dart:math';
import '../models/document.dart';

class DocumentService {
  static const String baseUrl = 'https://api.rysk.demo'; // Dummy endpoint

  // Simulate API call with dummy data
  Future<String> uploadDocument(List<File> images, String title) async {
    try {
      print('⏳ [MOCK API] Starting upload simulation...');

      // Simulate network delay with timeout
      await Future.delayed(const Duration(seconds: 2)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Upload timeout after 10 seconds');
        },
      );

      // Generate dummy document ID
      final documentId = 'doc_${DateTime.now().millisecondsSinceEpoch}';

      print(
        '📤 [MOCK API] Uploading document: $title with ${images.length} images',
      );
      print('📤 [MOCK API] Document ID: $documentId');

      return documentId;
    } catch (e) {
      print('❌ [MOCK API] Upload failed: $e');
      rethrow;
    }
  }

  // Simulate document processing
  Future<DocumentAnalysis> processDocument(String documentId) async {
    try {
      print('⏳ [MOCK API] Starting processing simulation...');

      // Simulate processing time with timeout
      await Future.delayed(const Duration(seconds: 3)).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Processing timeout after 15 seconds');
        },
      );

      // Generate mock analysis data
      final analysis = _generateMockAnalysis();

      print('🔍 [MOCK API] Document $documentId processing complete');
      print('🔍 [MOCK API] Risk Score: ${analysis.overallRiskScore}');

      return analysis;
    } catch (e) {
      print('❌ [MOCK API] Processing failed: $e');
      rethrow;
    }
  }

  // Generate realistic mock data for testing
  DocumentAnalysis _generateMockAnalysis() {
    final random = Random();
    final riskScore = 25 + random.nextDouble() * 50; // 25-75 range

    String riskLevel;
    if (riskScore < 30) {
      riskLevel = 'Low';
    } else if (riskScore < 60) {
      riskLevel = 'Medium';
    } else if (riskScore < 80) {
      riskLevel = 'High';
    } else {
      riskLevel = 'Critical';
    }

    final mockClauses = [
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
        title: 'Exclusive Jurisdiction',
        description: 'Legal disputes must be resolved in inconvenient location',
        clause:
            'Any disputes shall be resolved exclusively in the courts of [Remote Location].',
        riskLevel: 6,
        explanation:
            'This clause forces you to litigate in a potentially expensive and inconvenient location.',
        recommendations: [
          'Negotiate mutual jurisdiction',
          'Consider arbitration instead',
          'Choose neutral location',
        ],
      ),
      RiskyClause(
        id: 'clause_5',
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

    // Select random clauses for variety
    final selectedClauses = (mockClauses..shuffle()).take(3).toList();

    return DocumentAnalysis(
      overallRiskScore: riskScore,
      riskLevel: riskLevel,
      topRiskyClauses: selectedClauses,
      extractedText: '''
PROFESSIONAL SERVICES AGREEMENT

This Professional Services Agreement ("Agreement") is entered into on [Date] between [Company A] and [Company B].

1. SCOPE OF WORK
The Contractor agrees to provide professional consulting services as detailed in Exhibit A.

2. COMPENSATION
Client shall pay Contractor a total fee of \$[Amount] for the services described herein.

3. LIABILITY
Party A shall be liable for any and all damages, costs, and expenses arising from or related to this agreement, without limitation.

4. INDEMNIFICATION
Party A agrees to indemnify and hold harmless Party B from any claims, damages, or losses.

5. TERM AND TERMINATION
This agreement shall automatically renew for successive one-year periods unless terminated.

6. GOVERNING LAW
This Agreement shall be governed by the laws of [State/Country].
      ''',
      metadata: {
        'documentType': 'Professional Services Agreement',
        'pageCount': random.nextInt(5) + 1,
        'processingTime': '3.2 seconds',
        'confidence': 0.85 + random.nextDouble() * 0.1,
      },
    );
  }
}
