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
    final dynamicMinutes = _estimateReadingMinutes(article);

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
                      '$dynamicMinutes min read',
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

  int _estimateReadingMinutes(ArticleData article) {
    final buffer = StringBuffer();
    for (final section in article.sections) {
      for (final content in section.content) {
        buffer.write('${content.text} ');
      }
    }
    final text = buffer.toString().trim();
    if (text.isEmpty) return article.readingTime;
    final wordCount = RegExp(r'\w+').allMatches(text).length;
    final minutes = (wordCount / 200).ceil();
    return minutes < 1 ? 1 : minutes;
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
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Assignment - Who can transfer the contract to someone else',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Severability - If one clause is invalid, the rest still apply',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Entire Agreement - This document overrides previous discussions',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Notice - How official communications must be sent (email/mail)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Waiver - Not enforcing a right once doesn\'t waive it forever',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Confidentiality - What information must be kept private',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Term & Termination - How long it lasts and how it can end',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Non‑compete / Non‑solicit - Limits on competing or hiring (varies by region)',
                ),
              ],
            ),
          ],
        );

      case 'red-flags':
        return ArticleData(
          subtitle: 'Common problematic clauses and how to spot them fast',
          readingTime: 6,
          sections: [
            ArticleSection(
              title: 'Top Red Flags',
              content: [
                ArticleContent(
                  type: ContentType.paragraph,
                  text:
                      'These clauses can expose you to unnecessary risk or lock you into unfair terms. If you see these, pause and review carefully:',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Unlimited Liability — No cap on the amount you can be held responsible for',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Broad Indemnification — You\'re covering losses beyond your control (including the other party\'s mistakes)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Automatic Renewal without Notice — Contract renews by default and is easy to miss',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'One-sided Termination — They can end it anytime; you can\'t',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'IP Assignment (Too Broad) — Transfers all your work and related know‑how with no carve‑outs',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Jurisdiction/Venue Far Away — Forces disputes in an inconvenient or expensive location',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Confidentiality with Carve‑outs Missing — No protection for your trade secrets if they leak via third parties',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Payment Terms with Long Delays — Cash flow risk (e.g., Net 60/90) without late fees',
                ),
                ArticleContent(
                  type: ContentType.highlight,
                  text:
                      'Quick check: Is it balanced? If every obligation is on you and every right is on them, negotiate.',
                ),
              ],
            ),
            ArticleSection(
              title: 'What to do if you spot a red flag',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Ask for limits — Add a reasonable liability cap (e.g., 12 months of fees) and exclude indirect damages',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Balance obligations — Make indemnities mutual or narrow them to your own actions only',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Add notice — Require reminder emails before auto-renew; allow termination for convenience with short notice',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Carve out your IP — Keep pre‑existing IP and general know‑how; define ownership of deliverables clearly',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Choose neutral forum — Use your home state/country or neutral arbitration',
                ),
              ],
            ),
          ],
        );

      case 'negotiation-tips':
        return ArticleData(
          subtitle: 'Practical steps to get fairer, safer contract terms',
          readingTime: 6,
          sections: [
            ArticleSection(
              title: 'Before you negotiate',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Prioritize must‑haves vs nice‑to‑haves — Focus on risk, cost, and lock‑in first',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Know your fallback — Decide in advance when you\'d walk away',
                ),
                ArticleContent(
                  type: ContentType.highlight,
                  text:
                      'Bring examples — Propose specific alternative wording. It\'s easier to accept than to draft from scratch.',
                ),
              ],
            ),
            ArticleSection(
              title: 'During negotiation',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Trade, don\'t concede — If you give on price, get better payment terms or a liability cap in return',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Be specific — Replace vague terms with concrete numbers (e.g., \"99.9% uptime\", \"30‑day notice\")',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Time‑box renewals — Shorter initial terms and renewal windows reduce lock‑in risk',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Escalate politely — If stuck, bring in someone senior or switch to written comments to reduce friction',
                ),
              ],
            ),
            ArticleSection(
              title: 'After agreement',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Save the final PDF and a summary of key terms (fees, term, renewals, caps)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Calendar reminders — Add renewal and notice dates so you don\'t miss them',
                ),
              ],
            ),
          ],
        );

      case 'industry-standards':
        return ArticleData(
          subtitle:
              'Typical terms you\'ll see by contract type (not legal advice)',
          readingTime: 7,
          sections: [
            ArticleSection(
              title: 'SaaS Agreements (typical ranges)',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Liability cap — 6–12 months of fees; often excludes indirect damages',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Uptime/SLA — 99.9% is common; credits for extended downtime',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Auto‑renewal — 12‑month terms; 30‑60 day notice to cancel',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Data protection — DPA + sub‑processors listed; security commitments defined',
                ),
              ],
            ),
            ArticleSection(
              title: 'Professional Services / Consulting',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Deliverables & acceptance — Clear milestones and sign‑off criteria',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'IP ownership — Often client‑owned deliverables; vendor keeps pre‑existing IP',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Expenses — Pre‑approval for travel; invoicing cycles 30 days typical',
                ),
              ],
            ),
            ArticleSection(
              title: 'NDAs (Confidentiality)',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Mutual NDAs are common — Both sides owe the same duties',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Term — 1–3 years for confidentiality; carve‑outs for public/independently developed info',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Return/Destroy — On request or at project end',
                ),
              ],
            ),
            ArticleSection(
              title: 'Residential Leases (Rentals)',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Security deposit — Often 1–2 months\' rent; check refund conditions and timeline',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Notice to end lease — 30 days typical for month‑to‑month; fixed terms specify end date',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Maintenance — Who fixes what (landlord vs tenant responsibilities)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Late fees — Caps or grace periods may apply (varies by location)',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Pets — Deposits/fees, breed restrictions, and damages',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Early termination — Fees or subletting rules if you need to leave early',
                ),
              ],
            ),
            ArticleSection(
              title: 'HOA (Homeowners Association) Agreements',
              content: [
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text: 'Assessments/dues — Amount, due dates, late penalties',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Rules — Noise, parking, exterior changes, short‑term rentals',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Architectural approvals — Process and timelines for modifications',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Fines & enforcement — How violations are handled; appeal options',
                ),
                ArticleContent(
                  type: ContentType.bulletPoint,
                  text:
                      'Common areas — Responsibilities, hours, guest policies',
                ),
              ],
            ),
            ArticleSection(
              title: 'Keep in mind',
              content: [
                ArticleContent(
                  type: ContentType.highlight,
                  text:
                      'These are typical patterns, not rules. Always consider your context and, if needed, get legal advice.',
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
