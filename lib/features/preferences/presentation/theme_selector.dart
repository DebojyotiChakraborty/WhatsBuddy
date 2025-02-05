import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final Function(ThemeMode) onThemeSelected;
  final bool isDark;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[800]!.withOpacity(0.98)
            : Colors.white.withOpacity(0.98),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context,
            'System',
            'assets/icons/sun-moon.svg',
            currentTheme == ThemeMode.system,
            () => onThemeSelected(ThemeMode.system),
          ),
          _buildDivider(),
          _buildThemeOption(
            context,
            'Light',
            'assets/icons/sun_line.svg',
            currentTheme == ThemeMode.light,
            () => onThemeSelected(ThemeMode.light),
          ),
          _buildDivider(),
          _buildThemeOption(
            context,
            'Dark',
            'assets/icons/moon_line.svg',
            currentTheme == ThemeMode.dark,
            () => onThemeSelected(ThemeMode.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String iconPath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
    );
  }
}
