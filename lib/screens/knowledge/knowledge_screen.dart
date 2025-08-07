import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'knowledge_article_screen.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Knowledge',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KnowledgeCard(
            title: 'Contract Basics',
            description:
                'Learn the fundamentals of contract analysis and what to look for',
            icon: Icons.description_outlined,
            iconColor: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'contract-basics',
                    title: 'Contract Basics',
                    iconColor: Color(0xFF3B82F6),
                    icon: Icons.description_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Risk Assessment',
            description:
                'Understanding different risk levels and what they mean for you',
            icon: Icons.security_outlined,
            iconColor: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'risk-assessment',
                    title: 'Risk Assessment',
                    iconColor: Color(0xFFF59E0B),
                    icon: Icons.security_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Legal Terms Dictionary',
            description:
                'Common legal terminology and clauses explained in plain language',
            icon: Icons.menu_book_outlined,
            iconColor: const Color(0xFF10B981),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'legal-terms',
                    title: 'Legal Terms Dictionary',
                    iconColor: Color(0xFF10B981),
                    icon: Icons.menu_book_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Red Flags to Watch',
            description: 'Common problematic clauses and how to identify them',
            icon: Icons.warning_outlined,
            iconColor: const Color(0xFFEF4444),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'red-flags',
                    title: 'Red Flags to Watch',
                    iconColor: Color(0xFFEF4444),
                    icon: Icons.warning_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Negotiation Tips',
            description:
                'How to negotiate better terms and protect your interests',
            icon: Icons.handshake_outlined,
            iconColor: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'negotiation-tips',
                    title: 'Negotiation Tips',
                    iconColor: Color(0xFF8B5CF6),
                    icon: Icons.handshake_outlined,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Industry Standards',
            description:
                'Typical contract terms across different industries and sectors',
            icon: Icons.business_center_outlined,
            iconColor: const Color(0xFF06B6D4),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KnowledgeArticleScreen(
                    articleId: 'industry-standards',
                    title: 'Industry Standards',
                    iconColor: Color(0xFF06B6D4),
                    icon: Icons.business_center_outlined,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KnowledgeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
