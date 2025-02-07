import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

class PreferencesScreen extends ConsumerWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Column(
                  children: [
                    Text(
                      'Preferences',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Adjust your settings or\nknow more about the app',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .extension<AppThemeExtension>()
                          ?.secondaryText
                          .copyWith(
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAppearanceCard(context, ref, themeMode),
                  _buildPreferenceCard(
                    context,
                    icon: 'assets/icons/directory_line.svg',
                    title: 'Status file location',
                    subtitle: '... /Media/.Statuses',
                  ),
                  _buildPreferenceCard(
                    context,
                    icon: 'assets/icons/drink_line.svg',
                    title: 'Donate or Support',
                    subtitle: 'Support me on Kofi',
                    onTap: () =>
                        _launchURL('https://ko-fi.com/stellar_studios'),
                  ),
                  _buildPreferenceCard(
                    context,
                    icon: 'assets/icons/github_line.svg',
                    title: 'Github Repository',
                    subtitle: 'Review the codebase',
                    onTap: () => _launchURL(
                        'https://github.com/DebojyotiChakraborty/WhatsBuddy'),
                  ),
                  _buildPreferenceCard(
                    context,
                    icon: 'assets/icons/information_line.svg',
                    title: 'View Onboarding',
                    subtitle: '',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: GestureDetector(
                      onTap: () => _launchURL('https://x.com/Pseudo_Maverick'),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context)
                              .extension<AppThemeExtension>()
                              ?.secondaryText
                              .copyWith(
                                height: 1.5,
                              ),
                          children: [
                            const TextSpan(text: 'Made with '),
                            const TextSpan(
                              text: '❤️',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const TextSpan(text: ' and Flutter by '),
                            WidgetSpan(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/dev_avatar.jpg',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(
      BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: SquircleBorder(radius: BorderRadius.circular(24)),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/brush_3_line.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.black,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'GeistMono',
                ),
              ),
              const Spacer(),
              PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    onTap: () {
                      ref
                          .read(themeNotifierProvider.notifier)
                          .setTheme(ThemeMode.system);
                    },
                    title: 'System',
                  ),
                  PullDownMenuItem(
                    onTap: () {
                      ref
                          .read(themeNotifierProvider.notifier)
                          .setTheme(ThemeMode.light);
                    },
                    title: 'Light',
                  ),
                  PullDownMenuItem(
                    onTap: () {
                      ref
                          .read(themeNotifierProvider.notifier)
                          .setTheme(ThemeMode.dark);
                    },
                    title: 'Dark',
                  ),
                ],
                position: PullDownMenuPosition.over,
                buttonBuilder: (context, showMenu) => GestureDetector(
                  onTap: showMenu,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getThemeModeText(currentTheme),
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.54),
                          fontFamily: 'GeistMono',
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/selector_vertical_line.svg',
                        width: 28,
                        height: 28,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.54),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: SquircleBorder(radius: BorderRadius.circular(24)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: SquircleBorder(radius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  icon,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.black,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'GeistMono',
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.54),
                            fontFamily: 'GeistMono',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
