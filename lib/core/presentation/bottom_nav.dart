import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsbuddy/core/presentation/bottom_nav_item.dart';
import 'package:whatsbuddy/core/presentation/bottom_nav_item_button.dart';

/// Provider for the current navigation index
final navIndexProvider = StateProvider<int>((ref) => 0);

/// A custom bottom navigation bar with dot animation effect.
class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  ConsumerState<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  static const double _dotSize = 4.0;
  static const double _bottomPadding = 20.0;
  static const double _navBarHeight = 80.0;
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _verticalSpacing = 8.0;

  bool _isAnimating = false;
  bool _isForward = false;
  late double _maxWidth;
  late double _itemWidth;
  late double _dotWidth;
  late double _dotPosition;

  /// The list of navigation items
  static final List<BottomNavItem> _items = [
    const BottomNavItem(
      icon: 'chat_3_line',
      activeIcon: 'chat_3_fill',
      label: 'Chats',
      selectedColor: null,
    ),
    const BottomNavItem(
      icon: 'sandglass_line',
      activeIcon: 'sandglass_fill',
      label: 'Contacts',
      selectedColor: null,
    ),
    const BottomNavItem(
      icon: 'pic_line',
      activeIcon: 'pic_fill',
      label: 'Status',
      selectedColor: null,
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDimensions();
  }

  /// Updates the dimensions based on screen size
  void _updateDimensions() {
    _maxWidth = MediaQuery.of(context).size.width;
    _itemWidth = _maxWidth / _items.length;
    _dotWidth = _dotSize;
    _dotPosition = _calculateDotPosition(ref.read(navIndexProvider));
  }

  /// Calculate the dot position for a given index
  double _calculateDotPosition(int index) {
    return (index * _itemWidth) + (_itemWidth - _dotSize) / 2;
  }

  /// Handles tap on navigation items
  void _onTap(int index) {
    if (_isAnimating) return;
    final currentIndex = ref.read(navIndexProvider);
    if (currentIndex == index) return;

    _animateIndicator(currentIndex, index);
    ref.read(navIndexProvider.notifier).state = index;
  }

  /// Animates the dot indicator between items
  void _animateIndicator(int currentIndex, int newIndex) async {
    final newPosition = _calculateDotPosition(newIndex);
    final currentPosition = _calculateDotPosition(currentIndex);
    final isMovingForward = newIndex > currentIndex;
    final distance = (newPosition - currentPosition).abs();

    setState(() {
      _isAnimating = true;
      _isForward = isMovingForward;
      _dotPosition = isMovingForward ? currentPosition : newPosition;
      _dotWidth = distance + _dotSize;
    });

    await Future.delayed(_animationDuration);

    setState(() {
      _dotWidth = _dotSize;
      _dotPosition = newPosition;
      _isAnimating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: _navBarHeight + bottomPadding,
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildNavigationItems(currentIndex, theme),
          _buildAnimatedIndicator(currentIndex, bottomPadding, theme),
        ],
      ),
    );
  }

  /// Builds the row of navigation items
  Widget _buildNavigationItems(int currentIndex, ThemeData theme) {
    return Row(
      children: _items.asMap().entries.map((entry) {
        return BottomNavItemButton(
          item: entry.value.copyWith(
            selectedColor: theme.colorScheme.primary,
          ),
          isActive: currentIndex == entry.key,
          onTap: () => _onTap(entry.key),
          duration: _animationDuration,
          verticalPadding: _verticalSpacing,
        );
      }).toList(),
    );
  }

  /// Builds the animated dot indicator
  Widget _buildAnimatedIndicator(
      int currentIndex, double bottomPadding, ThemeData theme) {
    return AnimatedPositioned(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      bottom: bottomPadding + _bottomPadding,
      left: _dotPosition,
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        height: _dotSize,
        width: _dotWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_dotSize / 2),
          gradient: LinearGradient(
            begin: _isForward ? Alignment.centerLeft : Alignment.centerRight,
            end: _isForward ? Alignment.centerRight : Alignment.centerLeft,
            colors: [
              theme.colorScheme.primary.withOpacity(_isAnimating ? 0.4 : 1),
              theme.colorScheme.primary.withOpacity(_isAnimating ? 0.7 : 1),
              theme.colorScheme.primary,
            ],
          ),
        ),
      ),
    );
  }
}
