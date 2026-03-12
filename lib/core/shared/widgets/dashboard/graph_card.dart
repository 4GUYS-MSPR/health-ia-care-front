import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher une carte graphique avec un titre, un sous-titre et un enfant.
class GraphCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const GraphCard({required this.title, this.subtitle, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
            const SizedBox(height: 16),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}
