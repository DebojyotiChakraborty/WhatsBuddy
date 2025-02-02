import 'package:flutter/material.dart';

/// A model class representing an item in the bottom navigation bar.
/// Each item has a normal icon, active icon, label, and selected color.
@immutable
class BottomNavItem {
  /// The icon to display when the item is not selected
  final String icon;

  /// The icon to display when the item is selected
  final String activeIcon;

  /// The label text for the item
  final String label;

  /// The color to use when the item is selected
  /// If null, will use the theme's primary color
  final Color? selectedColor;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.selectedColor,
  });

  /// Creates a copy of this BottomNavItem with the given fields replaced with new values
  BottomNavItem copyWith({
    String? icon,
    String? activeIcon,
    String? label,
    Color? selectedColor,
  }) {
    return BottomNavItem(
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}
