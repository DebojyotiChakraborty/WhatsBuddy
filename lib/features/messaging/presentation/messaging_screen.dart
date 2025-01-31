import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsbuddy/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

import '../../messaging/data/messaging_repository.dart';
import '../data/message_history_model.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber? _selectedNumber;

  void _openWhatsAppChat() async {
    final cleanNumber = _selectedNumber?.completeNumber ?? '';

    if (cleanNumber.isEmpty || !cleanNumber.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid international number')),
      );
      return;
    }

    final url = Uri.parse('${AppConstants.whatsappUrlScheme}$cleanNumber');

    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch WhatsApp');
      }
      await MessagingRepository.addToHistory(cleanNumber);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('WhatsApp not installed'),
          action: SnackBarAction(
            label: 'Install',
            onPressed: () => launchUrl(Uri.parse(
                'https://play.google.com/store/apps/details?id=com.whatsapp')),
          ),
        ),
      );
    }
  }

  void _openWhatsAppDirectly(String phoneNumber) async {
    final url = Uri.parse('${AppConstants.whatsappUrlScheme}$phoneNumber');

    try {
      if (!await launchUrl(url)) {
        throw Exception('Could not launch WhatsApp');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              IntlPhoneField(
                controller: _phoneController,
                initialCountryCode: 'IN',
                disableLengthCheck: true,
                showCountryFlag: false,
                dropdownIcon: const Icon(Icons.arrow_drop_down),
                searchText: 'Search country',
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                onChanged: (number) => _selectedNumber = number,
              ),
              _buildHistorySection(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsAppChat,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    return FutureBuilder<List<MessageHistory>>(
      future: MessagingRepository.getHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Recent Messages',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length + 1,
              itemBuilder: (context, index) {
                if (index == snapshot.data!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.delete),
                      label: const Text('Clear History'),
                      onPressed: () async {
                        await MessagingRepository.clearHistory();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared')),
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                }
                final history = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(history.phoneNumber),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy - hh:mm a')
                          .format(history.timestamp),
                    ),
                    onTap: () => _openWhatsAppDirectly(history.phoneNumber),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
