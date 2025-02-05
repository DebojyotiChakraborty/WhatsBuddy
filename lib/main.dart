import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsbuddy/core/theme/app_theme.dart';
import 'package:whatsbuddy/core/providers/theme_provider.dart';
import 'package:whatsbuddy/features/contacts/data/contact_model.dart';
import 'package:whatsbuddy/features/messaging/data/message_history_model.dart';
import 'package:heroine/heroine.dart';
import 'package:whatsbuddy/core/presentation/page_transition.dart';
import 'package:whatsbuddy/features/onboarding/presentation/onboarding_screen.dart';
import 'package:whatsbuddy/features/preferences/presentation/preferences_screen.dart';

import 'core/presentation/bottom_nav.dart';
import 'features/contacts/presentation/contacts_screen.dart';
import 'features/messaging/presentation/messaging_screen.dart';
import 'features/status/presentation/status_screen.dart';
import 'features/status/data/status_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ContactAdapter());
  Hive.registerAdapter(MessageHistoryAdapter());
  await Hive.openBox<Contact>('contacts');
  await Hive.openBox<MessageHistory>('messageHistory');
  StatusRepository.setupDirectoryListener();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<bool> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('hasCompletedOnboarding') ?? false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'WhatsBuddy',
      navigatorObservers: [HeroineController()],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
        scrollbars: false,
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ));
        return child!;
      },
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _checkFirstLaunch(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true
                    ? const OnboardingScreen()
                    : const HomeNavigator();
              },
            ),
        '/messaging': (context) => const MessagingScreen(),
      },
    );
  }
}

class HomeNavigator extends ConsumerWidget {
  const HomeNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final screens = [
      const MessagingScreen(),
      const ContactsScreen(),
      const StatusScreen(),
      const PreferencesScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens.asMap().entries.map((entry) {
          return PageTransition(
            isActive: currentIndex == entry.key,
            child: entry.value,
          );
        }).toList(),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
