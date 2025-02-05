import 'package:flutter/material.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;
    final textColor = isDark ? Colors.white70 : Colors.black54;

    return CupertinoOnboarding(
      onPressedOnLastPage: () => _completeOnboarding(context),
      bottomButtonColor: Theme.of(context).colorScheme.primary,
      bottomButtonChild: Text(
        'Continue',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontFamily: 'Geist',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      widgetAboveBottomButton: const SizedBox(height: 20),
      pages: [
        WhatsbuddyOnboardingPage(
          title: 'Message Without Saving',
          description:
              'Chat with phone numbers without saving them to your device. Keep your contacts list clean and organized.',
          image: SvgPicture.asset(
            'assets/icons/chat_3_fill.svg',
            height: 120,
            width: 120,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          textColor: textColor,
          titleColor: iconColor,
        ),
        WhatsbuddyOnboardingPage(
          title: 'Temporary Contacts',
          description:
              'Add temporary contacts that automatically delete after 24 hours. Perfect for one-time conversations.',
          image: SvgPicture.asset(
            'assets/icons/sandglass_fill.svg',
            height: 120,
            width: 120,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          textColor: textColor,
          titleColor: iconColor,
        ),
        WhatsbuddyOnboardingPage(
          title: 'Status Saver',
          description:
              'Easily save and share any status you\'ve viewed. Never miss out on important moments.',
          image: SvgPicture.asset(
            'assets/icons/pic_fill.svg',
            height: 120,
            width: 120,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          textColor: textColor,
          titleColor: iconColor,
        ),
        WhatsbuddyOnboardingPage(
          title: 'Beautiful Design',
          description:
              'A thoughtfully designed and optimized UI that makes navigating through the app a delightful experience.',
          image: SvgPicture.asset(
            'assets/icons/check_circle_fill.svg',
            height: 120,
            width: 120,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          textColor: textColor,
          titleColor: iconColor,
        ),
      ],
    );
  }
}

class WhatsbuddyOnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final Widget image;
  final Color textColor;
  final Color titleColor;

  const WhatsbuddyOnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.textColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoOnboardingPage(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Geist',
          color: titleColor,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          image,
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontFamily: 'Geist',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
