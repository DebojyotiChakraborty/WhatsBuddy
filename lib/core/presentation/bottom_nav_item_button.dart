import 'package:flutter/material.dart';
import 'package:whatsbuddy/core/presentation/bottom_nav_item.dart';
import 'package:whatsbuddy/core/presentation/svg_icon.dart';

/// A button widget used in the bottom navigation bar.
/// Handles the display and animation of a single navigation item.
class BottomNavItemButton extends StatelessWidget {
  static const double _defaultIconSize = 24.0;
  static const double _defaultJumpHeight = 4.0;
  static const double _defaultHorizontalPadding = 6.0;
  static const double _defaultVerticalPadding = 4.0;

  /// The navigation item data
  final BottomNavItem item;

  /// Whether this item is currently selected
  final bool isActive;

  /// Callback when the item is tapped
  final VoidCallback onTap;

  /// Duration for the animation
  final Duration duration;

  /// Whether the icon should jump when selected
  final bool iconJump;

  /// Horizontal padding for the item
  final double horizontalPadding;

  /// Vertical padding for the item
  final double verticalPadding;

  const BottomNavItemButton({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.duration,
    this.iconJump = true,
    this.horizontalPadding = _defaultHorizontalPadding,
    this.verticalPadding = _defaultVerticalPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = item.selectedColor ?? theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withOpacity(0.64);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.fastOutSlowIn,
            transform: Matrix4.identity()
              ..translate(
                0.0,
                iconJump && isActive ? -_defaultJumpHeight : 0.0,
                0.0,
              ),
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: SvgIcon.asset(
                isActive ? item.activeIcon : item.icon,
                size: _defaultIconSize,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
