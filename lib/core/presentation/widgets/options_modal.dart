import 'package:flutter/material.dart';
import 'dart:ui';
import 'custom_text_field.dart';
import '../../theme/app_theme.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';

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
          decoration: ShapeDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            shape: SquircleBorder(radius: BorderRadius.circular(44)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (inputController != null) ...[
                const SizedBox(height: 24),
                CustomTextField(
                  controller: inputController,
                  hintText: inputHint,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                  style: Theme.of(context).textTheme.bodyLarge,
                  hintStyle: Theme.of(context)
                      .extension<AppThemeExtension>()
                      ?.hintStyle,
                  prefixIcon: inputIcon,
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
        final shape = SquircleBorder(radius: BorderRadius.circular(24));
        return Container(
          width: double.infinity,
          height: 56,
          decoration: ShapeDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[100],
            shape: shape,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: option.onTap,
              customBorder: shape,
              child: Center(
                child: Text(
                  option.label,
                  style: Theme.of(context).textTheme.labelLarge,
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
        final textStyle = Theme.of(context).textTheme.labelMedium;
        final shape = SquircleBorder(radius: BorderRadius.circular(32));
        return Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            color: isDark ? Colors.grey[800] : Colors.white,
            shape: shape,
            shadows: [
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
              customBorder: shape,
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
                    style: option.isDestructive
                        ? textStyle?.copyWith(color: Colors.red[300])
                        : textStyle,
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
