import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsbuddy/core/presentation/svg_icon.dart';

import '../../../core/constants/app_constants.dart';
import '../data/contact_model.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Temporary Contacts')),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Contact>('contacts').listenable(),
        builder: (context, Box<Contact> box, _) {
          final contacts = box.values.toList().reversed.toList();
          if (contacts.isEmpty) {
            return const Center(
              child: Text('No temporary contacts found'),
            );
          }
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Dismissible(
                key: Key(contact.number),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Contact?'),
                      content:
                          const Text('This will remove the temporary contact'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                movementDuration: const Duration(milliseconds: 200),
                resizeDuration: const Duration(milliseconds: 200),
                dismissThresholds: const {DismissDirection.endToStart: 0.5},
                onDismissed: (direction) => box.deleteAt(index),
                child: InkWell(
                  onTap: () => _showContactOptions(context, contact, index),
                  child: ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.number),
                    trailing: _buildExpiryIndicator(contact.createdAt),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpiryIndicator(DateTime createdAt) {
    final expiryTime =
        createdAt.add(const Duration(hours: AppConstants.contactExpiryHours));
    final remaining = expiryTime.difference(DateTime.now());
    final progress =
        remaining.inSeconds / (AppConstants.contactExpiryHours * 3600);

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress < 0 ? 1 : 1 - progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
                progress < 0 ? Colors.red : Colors.green),
          ),
          Text(
            '${remaining.inHours.remainder(24)}h',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    PhoneNumber? phoneNumber;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Temporary Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                hintText: 'Enter name',
              ),
            ),
            const SizedBox(height: 16),
            IntlPhoneField(
              controller: phoneController,
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
              onChanged: (number) => phoneNumber = number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final number = phoneNumber?.completeNumber ?? '';

              if (name.isEmpty || number.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              final contactsBox = Hive.box<Contact>('contacts');
              contactsBox.add(Contact(
                name: name,
                number: number,
                createdAt: DateTime.now(),
              ));

              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showContactOptions(BuildContext context, Contact contact, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: SvgIcon.asset('user_add_2_line', size: 24),
            title: const Text('Message'),
            onTap: () {
              Navigator.pop(context);
              _openWhatsAppChat(context, contact.number);
            },
          ),
          ListTile(
            leading: SvgIcon.asset('user_add_2_line', size: 24),
            title: const Text('Save to Device'),
            onTap: () => _saveToDeviceContacts(context, contact),
          ),
          ListTile(
            leading: SvgIcon.asset('user_add_2_line', size: 24),
            title: const Text('Delete'),
            onTap: () => _deleteContact(context, index),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsAppChat(BuildContext context, String number) async {
    final url = Uri.parse('${AppConstants.whatsappUrlScheme}$number');
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

  Future<void> _saveToDeviceContacts(
      BuildContext context, Contact contact) async {
    try {
      final newContact = fc.Contact()
        ..name.first = contact.name
        ..phones.add(fc.Phone(contact.number));

      await fc.FlutterContacts.openExternalInsert(newContact);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open contacts app')),
      );
    }
  }

  void _deleteContact(BuildContext context, int index) {
    final box = Hive.box<Contact>('contacts');
    box.deleteAt(index);
    Navigator.pop(context);
  }
}
