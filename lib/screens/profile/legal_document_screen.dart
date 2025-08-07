import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LegalDocumentType { terms, privacy, cookies, dataUsage }

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final LegalDocumentType documentType;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.documentType,
  });

  @override
  Widget build(BuildContext context) {
    final content = _getDocumentContent(documentType);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF6B7280)),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last updated
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Last updated: December 2024',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Content
              ...content.map((section) => _buildSection(section)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(LegalSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title.isNotEmpty) ...[
          Text(
            section.title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
        ],

        ...section.paragraphs.map(
          (paragraph) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              paragraph,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  List<LegalSection> _getDocumentContent(LegalDocumentType type) {
    switch (type) {
      case LegalDocumentType.terms:
        return [
          LegalSection(
            title: 'Terms of Service',
            paragraphs: [
              'Welcome to Rysk. These Terms of Service ("Terms") govern your use of our mobile application and services.',
              'By accessing or using Rysk, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our service.',
            ],
          ),
          LegalSection(
            title: '1. Use of Service',
            paragraphs: [
              'Rysk provides contract analysis services using artificial intelligence. Our service is designed to help you understand potential risks in legal documents.',
              'You must be at least 18 years old to use our service. You are responsible for maintaining the confidentiality of your account and password.',
            ],
          ),
          LegalSection(
            title: '2. Document Analysis',
            paragraphs: [
              'Our AI analyzes documents you upload to identify potential risks and clauses of concern. The analysis provided is for informational purposes only and should not be considered legal advice.',
              'Always consult with qualified legal professionals for legal advice specific to your situation.',
            ],
          ),
          LegalSection(
            title: '3. Privacy and Data',
            paragraphs: [
              'We take your privacy seriously. Documents you upload are processed securely and are not shared with third parties without your consent.',
              'For detailed information about how we handle your data, please see our Privacy Policy.',
            ],
          ),
          LegalSection(
            title: '4. Limitation of Liability',
            paragraphs: [
              'Rysk is provided "as is" without warranties of any kind. We are not liable for any decisions you make based on our analysis.',
              'Our liability is limited to the maximum extent permitted by law.',
            ],
          ),
          LegalSection(
            title: '5. Contact Us',
            paragraphs: [
              'If you have any questions about these Terms, please contact us at legal@rysk.app.',
            ],
          ),
        ];

      case LegalDocumentType.privacy:
        return [
          LegalSection(
            title: 'Privacy Policy',
            paragraphs: [
              'This Privacy Policy describes how Rysk collects, uses, and protects your personal information when you use our mobile application.',
            ],
          ),
          LegalSection(
            title: 'Information We Collect',
            paragraphs: [
              'We collect information you provide directly to us, such as when you create an account, upload documents, or contact us for support.',
              'This may include your name, email address, and the documents you choose to analyze.',
            ],
          ),
          LegalSection(
            title: 'How We Use Your Information',
            paragraphs: [
              'We use your information to provide and improve our contract analysis services, communicate with you, and ensure the security of our platform.',
              'Your documents are processed using AI to provide risk analysis and are not used for any other purpose without your consent.',
            ],
          ),
          LegalSection(
            title: 'Data Security',
            paragraphs: [
              'We implement appropriate technical and organizational measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.',
              'Your documents are encrypted in transit and at rest.',
            ],
          ),
          LegalSection(
            title: 'Your Rights',
            paragraphs: [
              'You have the right to access, update, or delete your personal information. You can also request a copy of your data or ask us to stop processing it.',
              'To exercise these rights, please contact us at privacy@rysk.app.',
            ],
          ),
          LegalSection(
            title: 'Changes to This Policy',
            paragraphs: [
              'We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new policy in the app.',
            ],
          ),
        ];

      case LegalDocumentType.cookies:
        return [
          LegalSection(
            title: 'Cookie Policy',
            paragraphs: [
              'This Cookie Policy explains how Rysk uses cookies and similar technologies when you use our mobile application.',
            ],
          ),
          LegalSection(
            title: 'What Are Cookies',
            paragraphs: [
              'Cookies are small data files that are placed on your device when you use our app. They help us provide a better user experience and understand how you interact with our service.',
            ],
          ),
          LegalSection(
            title: 'How We Use Cookies',
            paragraphs: [
              'We use cookies to remember your preferences, keep you logged in, and analyze app usage to improve our service.',
              'We do not use cookies for advertising or tracking across other websites or apps.',
            ],
          ),
          LegalSection(
            title: 'Managing Cookies',
            paragraphs: [
              'You can control cookies through your device settings, though disabling certain cookies may affect app functionality.',
              'For questions about our cookie usage, contact us at privacy@rysk.app.',
            ],
          ),
        ];

      case LegalDocumentType.dataUsage:
        return [
          LegalSection(
            title: 'Data Usage Policy',
            paragraphs: [
              'This policy explains how Rysk processes and uses the data you provide to deliver our contract analysis services.',
            ],
          ),
          LegalSection(
            title: 'Document Processing',
            paragraphs: [
              'When you upload a document, our AI systems analyze the text to identify potential risks and concerning clauses.',
              'Documents are processed securely in the cloud and are not stored longer than necessary to provide the analysis.',
            ],
          ),
          LegalSection(
            title: 'Data Retention',
            paragraphs: [
              'We retain your documents and analysis results for as long as you maintain your account, unless you choose to delete them earlier.',
              'You can delete individual documents or your entire account at any time through the app.',
            ],
          ),
          LegalSection(
            title: 'Third-Party Services',
            paragraphs: [
              'We use secure cloud services to process and store your data. These providers are bound by strict confidentiality agreements.',
              'We do not share your documents or personal information with third parties for marketing purposes.',
            ],
          ),
          LegalSection(
            title: 'Data Protection',
            paragraphs: [
              'All data transmission is encrypted using industry-standard protocols. Your documents are encrypted both in transit and at rest.',
              'We regularly review and update our security practices to protect your information.',
            ],
          ),
        ];
    }
  }
}

class LegalSection {
  final String title;
  final List<String> paragraphs;

  LegalSection({required this.title, required this.paragraphs});
}
