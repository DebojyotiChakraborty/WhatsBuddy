import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/presentation/widgets/options_modal.dart';
import '../../../core/theme/app_theme.dart';
import '../data/contact_model.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
                                                  const Color(0xFFE57373),
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
                                                      .colorScheme
                                                      .onSurface,
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
                                    color: Theme.of(context).colorScheme.error,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
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
                                      horizontal: 16, vertical: 4),
                                  decoration: ShapeDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    shape: SquircleBorder(
                                        radius: BorderRadius.circular(24)),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showContactOptions(
                                          context, contact, index),
                                      customBorder: SquircleBorder(
                                          radius: BorderRadius.circular(24)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/contacts_2_line.svg',
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
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
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                      fontFamily: 'GeistMono',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: contact.number
                                                              .split(' ')[0],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withOpacity(
                                                                    0.54),
                                                            fontFamily:
                                                                'GeistMono',
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text:
                                                              ' ${contact.number.split(' ')[1]}',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                            fontFamily:
                                                                'GeistMono',
                                                          ),
                                                        ),
                                                      ],
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.54),
                                                fontFamily: 'GeistMono',
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
              'assets/icons/delete_2_line.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFFE57373),
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
