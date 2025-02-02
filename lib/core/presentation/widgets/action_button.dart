import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onPressed;
  final bool isHorizontal;
  final bool isDestructive;

  const ActionButton({
    super.key,
    this.icon,
    required this.label,
    required this.onPressed,
    this.isHorizontal = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isHorizontal) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontFamily: 'Geist',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red[300]
                      : (isDark ? Colors.white : Colors.grey[900]),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDestructive
                      ? Colors.red[300]
                      : (isDark ? Colors.white : Colors.grey[900]),
                  fontSize: 14,
                  height: 1.2,
                  fontFamily: 'Geist',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
