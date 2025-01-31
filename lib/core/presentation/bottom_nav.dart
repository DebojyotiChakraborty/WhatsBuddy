import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: ref.watch(navIndexProvider),
      onTap: (index) => ref.read(navIndexProvider.notifier).state = index,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Message',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.photo_library),
          label: 'Status',
        ),
      ],
    );
  }
}
