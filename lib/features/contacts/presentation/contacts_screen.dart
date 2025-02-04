import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/presentation/widgets/options_modal.dart';
import '../../../core/theme/app_theme.dart';
import '../data/contact_model.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Contact>('contacts').listenable(),
          builder: (context, Box<Contact> box, _) {
            final contacts = box.values.toList().reversed.toList();
            return LayoutBuilder(
              builder: (context, constraints) {
                // Calculate if content needs scrolling
                const headerHeight = 150.0; // Approximate height of header
                const itemHeight =
                    88.0; // Height of each contact item (including margins)
                final totalContentHeight =
                    headerHeight + (contacts.length * itemHeight);
                final needsScrolling =
                    totalContentHeight > constraints.maxHeight;

                return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                        child: Column(
                          children: [
                            Text(
                              'Temporary Contacts',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Temporary Contacts are\nauto-deleted after 24 hrs',
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
                  ],
                  body: CustomScrollView(
                    physics: needsScrolling
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    slivers: [
                      if (contacts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No temporary contacts found',
                              style: Theme.of(context)
                                  .extension<AppThemeExtension>()
                                  ?.secondaryText,
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final contact = contacts[index];
                              return Dismissible(
                                key: ValueKey(contact.number +
                                    contact.createdAt.toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  return await showModalBottomSheet<bool>(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => OptionsModal(
                                          title:
                                              'Delete Contact?\nThis will remove the temporary contact',
                                          options: [
                                            OptionItem(
                                              icon: SvgPicture.asset(
                                                'assets/icons/delete_2_line.svg',
                                                width: 24,
                                                height: 24,
                                                colorFilter: ColorFilter.mode(
                                                  Colors.red[300]!,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              label: 'Delete',
                                              onTap: () {
                                                Navigator.pop(context, true);
                                              },
                                              isDestructive: true,
                                            ),
                                            OptionItem(
                                              icon: SvgPicture.asset(
                                                'assets/icons/forbid_circle_line.svg',
                                                width: 24,
                                                height: 24,
                                                colorFilter: ColorFilter.mode(
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? Colors.white
                                                      : Colors.grey[900]!,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                              label: 'Cancel',
                                              onTap: () {
                                                Navigator.pop(context, false);
                                              },
                                            ),
                                          ],
                                        ),
                                      ) ??
                                      false;
                                },
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[400],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.white),
                                ),
                                onDismissed: (direction) {
                                  // Find the actual index in the box
                                  final boxIndex =
                                      box.values.toList().indexOf(contact);
                                  if (boxIndex != -1) {
                                    box.deleteAt(boxIndex);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showContactOptions(
                                          context, contact, index),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/user_add_2_line.svg',
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                isDark
                                                    ? Colors.white70
                                                    : Colors.grey[600]!,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    contact.name,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontFamily: 'Geist',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    contact.number,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: isDark
                                                          ? Colors.white54
                                                          : Colors.grey[600],
                                                      fontFamily: 'GeistMono',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              _formatTimeLeft(
                                                  contact.createdAt),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.white54
                                                    : Colors.grey[600],
                                                fontFamily: 'Geist',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: contacts.length,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTimeLeft(DateTime createdAt) {
    final expiryTime =
        createdAt.add(const Duration(hours: AppConstants.contactExpiryHours));
    final remaining = expiryTime.difference(DateTime.now());

    if (remaining.inHours >= 1) {
      return '${remaining.inHours}h';
    } else if (remaining.inMinutes >= 1) {
      return '${remaining.inMinutes}mins';
    } else {
      return '${remaining.inSeconds}s';
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box<Contact>('contacts');
    final boxIndex = box.values.toList().indexOf(contact);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OptionsModal(
        title: 'Temporary Contact\nOptions',
        options: [
          OptionItem(
            icon: null,
            label: 'Add to device contacts',
            onTap: () {
              Navigator.pop(context);
              _saveToDeviceContacts(context, contact);
            },
            isHorizontal: true,
          ),
          OptionItem(
            icon: SvgPicture.asset(
              'assets/icons/whatsapp_line.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.grey[900]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Start Chat',
            onTap: () {
              Navigator.pop(context);
              _openWhatsAppChat(context, contact.number);
            },
          ),
          OptionItem(
            icon: SvgPicture.asset(
              'assets/icons/delete_2_line.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Colors.red[300]!,
                BlendMode.srcIn,
              ),
            ),
            label: 'Delete',
            onTap: () {
              if (boxIndex != -1) {
                box.deleteAt(boxIndex);
              }
              Navigator.pop(context);
            },
            isDestructive: true,
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
}
