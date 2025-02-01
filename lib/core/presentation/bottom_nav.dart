import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsbuddy/core/presentation/svg_icon.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
      items: [
        BottomNavigationBarItem(
          icon: SvgIcon.asset('chat_3_line', size: 24),
          activeIcon: SvgIcon.asset('chat_3_fill', size: 24),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: SvgIcon.asset('hourglass_line', size: 24),
          activeIcon: SvgIcon.asset('hourglass_fill', size: 24),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: SvgIcon.asset('pic_line', size: 24),
          activeIcon: SvgIcon.asset('pic_fill', size: 24),
          label: 'Status',
        ),
      ],
    );
  }
}
