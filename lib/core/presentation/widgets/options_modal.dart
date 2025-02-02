import 'package:flutter/material.dart';
import 'dart:ui';

class OptionsModal extends StatelessWidget {
  final String title;
  final List<OptionItem> options;
  final TextEditingController? inputController;
  final String? inputHint;
  final Widget? inputIcon;

  const OptionsModal({
    super.key,
    required this.title,
    required this.options,
    this.inputController,
    this.inputHint,
    this.inputIcon,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalOptions = options.where((o) => o.isHorizontal).toList();
    final squareOptions = options.where((o) => !o.isHorizontal).toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  fontFamily: 'Geist',
                ),
              ),
              if (inputController != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (inputIcon != null) ...[
                        inputIcon!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 16,
                            fontFamily: 'Geist',
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: inputHint,
                            hintStyle: TextStyle(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white38
                                  : Colors.grey[400],
                              fontSize: 16,
                              fontFamily: 'Geist',
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (horizontalOptions.isNotEmpty) ...[
                const SizedBox(height: 24),
                ...horizontalOptions.map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHorizontalOption(option),
                    )),
              ],
              if (squareOptions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: squareOptions.map((option) {
                    final isLast = option == squareOptions.last;
                    return Row(
                      children: [
                        _buildSquareOption(option),
                        if (!isLast) const SizedBox(width: 16),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalOption(OptionItem option) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
              onTap: option.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: Text(
                  option.label,
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
      },
    );
  }

  Widget _buildSquareOption(OptionItem option) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
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
              borderRadius: BorderRadius.circular(16),
              onTap: option.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (option.icon != null) ...[
                    option.icon!,
                    const SizedBox(height: 8),
                  ],
                  Text(
                    option.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: option.isDestructive
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
      },
    );
  }
}

class OptionItem {
  final Widget? icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool isHorizontal;

  const OptionItem({
    this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.isHorizontal = false,
  });
}
