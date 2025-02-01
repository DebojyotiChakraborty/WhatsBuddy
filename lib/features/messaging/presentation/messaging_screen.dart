import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsbuddy/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../../contacts/data/contact_model.dart';
import '../../messaging/data/messaging_repository.dart';
import '../data/message_history_model.dart';
import '../../../core/presentation/bottom_nav.dart';

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

  void _showSaveContactModal(BuildContext context) {
    final nameController = TextEditingController();
    final phoneNumber = _selectedNumber?.completeNumber ?? '';

    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Enter name for temporary contact',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneNumber.isNotEmpty) {
                      final contactsBox = Hive.box<Contact>('contacts');
                      contactsBox.putAt(
                          0,
                          Contact(
                            name: nameController.text,
                            number: phoneNumber,
                            createdAt: DateTime.now(),
                          ));
                      Navigator.pop(context);
                      ref.read(navIndexProvider.notifier).state = 1;
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.chat),
              label: const Text('Start Chat'),
              onPressed: _openWhatsAppChat,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save_alt),
              label: const Text('Save Temporarily'),
              onPressed: () => _showSaveContactModal(context),
            ),
          ],
        ),
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
