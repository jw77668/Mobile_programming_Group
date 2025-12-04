import 'package:flutter/material.dart';

class FAQSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const FAQSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ],
    );
  }
}
