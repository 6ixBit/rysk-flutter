import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KnowledgeArticleScreen extends StatelessWidget {
  final String articleId;
  final String title;
  final Color iconColor;
  final IconData icon;

  const KnowledgeArticleScreen({
    super.key,
    required this.articleId,
    required this.title,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final article = _getArticleContent(articleId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor.withOpacity(0.1), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 40, color: iconColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reading time
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
                      '${article.readingTime} min read',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Article content
                  ...article.sections.map((section) => _buildSection(section)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ArticleSection section) {
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

        ...section.content.map((content) {
          if (content.type == ContentType.paragraph) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                content.text,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.6,
                  color: const Color(0xFF374151),
                ),
              ),
            );
          } else if (content.type == ContentType.bulletPoint) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      content.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (content.type == ContentType.highlight) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 20, color: iconColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      content.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.6,
                        color: const Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }).toList(),

        const SizedBox(height: 32),
      ],
    );
  }

  ArticleData _getArticleContent(String articleId) {
    switch (articleId) {
      case 'contract-basics':
        return ArticleData(
          subtitle: 'Everything you need to know about contract fundamentals',
          readingTime: 5,
          sections: [
            ArticleSection(
              title: 'What is a Contract?',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'A contract is a legally binding agreement between two or more parties. It creates obligations that are enforceable by law. Understanding contracts is crucial for protecting your interests in any business or personal arrangement.',
                ),
                ArticleContent(
                  type: ContentType.highlight,
                  text:
                      'Key Point: Every contract must have offer, acceptance, consideration, and legal capacity to be valid.',
                ),
              ],
            ),
            ArticleSection(
              title: 'Essential Elements',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'Every valid contract must contain these essential elements:',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Offer - A clear proposal by one party',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Acceptance - Agreement to the terms by the other party',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Consideration - Something of value exchanged',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Legal capacity - All parties must be legally able to contract',
                ),
              ],
            ),
            ArticleSection(
              title: 'Types of Contracts',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'Contracts can be written or oral, though written contracts are generally preferable as they provide clear evidence of the agreement terms.',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Employment contracts - Define work relationships',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Service agreements - Outline service provisions',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Sales contracts - Cover purchase of goods',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Lease agreements - Property rental terms',
                ),
              ],
            ),
          ],
        );

      case 'risk-assessment':
        return ArticleData(
          subtitle: 'Learn to identify and evaluate contract risks',
          readingTime: 7,
          sections: [
            ArticleSection(
              title: 'Understanding Risk Levels',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'Risk assessment in contracts involves identifying potential problems that could affect your interests. Our AI analyzes contracts and assigns risk levels from low to critical.',
                ),
                ArticleContent(
                  type: ContentType.highlight,
                  text:
                      'Risk levels help you prioritize which clauses need immediate attention.',
                ),
              ],
            ),
            ArticleSection(
              title: 'Common Risk Factors',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Unlimited liability clauses that expose you to excessive financial risk',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Automatic renewal terms that lock you into long commitments',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Broad indemnification requirements',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Unclear termination conditions',
                ),
              ],
            ),
          ],
        );

      case 'legal-terms':
        return ArticleData(
          subtitle: 'Decode legal jargon with plain English explanations',
          readingTime: 6,
          sections: [
            ArticleSection(
              title: 'Common Legal Terms',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'Legal documents often contain complex terminology. Here are the most important terms explained in simple language:',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Indemnification - Agreeing to cover someone else\'s losses',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Force Majeure - Events beyond anyone\'s control (like natural disasters)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Liquidated Damages - Pre-agreed penalty amounts',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Governing Law - Which state/country\'s laws apply',
                ),
              ],
            ),
          ],
        );

      default:
        return ArticleData(
          subtitle: 'Learn more about this topic',
          readingTime: 3,
          sections: [
            ArticleSection(
              title: 'Coming Soon',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'This article is being prepared. Check back soon for comprehensive information on this topic.',
                ),
              ],
            ),
          ],
        );
    }
  }
}

class ArticleData {
  final String subtitle;
  final int readingTime;
  final List<ArticleSection> sections;

  ArticleData({
    required this.subtitle,
    required this.readingTime,
    required this.sections,
  });
}

class ArticleSection {
  final String title;
  final List<ArticleContent> content;

  ArticleSection({required this.title, required this.content});
}

class ArticleContent {
  final ContentType type;
  final String text;

  ArticleContent({required this.type, required this.text});
}

enum ContentType { paragraph, bulletPoint, highlight }
