import 'package:flutter/material.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text('Knowledge Base'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _KnowledgeCard(
            title: 'Contract Basics',
            description: 'Learn the fundamentals of contract analysis',
            icon: Icons.description,
            onTap: () {
              // TODO: Navigate to contract basics
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Risk Assessment',
            description: 'Understanding contract risk factors',
            icon: Icons.security,
            onTap: () {
              // TODO: Navigate to risk assessment
            },
          ),
          const SizedBox(height: 16),
          _KnowledgeCard(
            title: 'Legal Terms',
            description: 'Common legal terminology explained',
            icon: Icons.gavel,
            onTap: () {
              // TODO: Navigate to legal terms
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
  final VoidCallback onTap;

  const _KnowledgeCard({
    required this.title,
    required this.description,
    required this.icon,
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
