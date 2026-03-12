import 'package:flutter/material.dart';

/// Widget réutilisable pour afficher une légende colorée.
class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem(this.color, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
