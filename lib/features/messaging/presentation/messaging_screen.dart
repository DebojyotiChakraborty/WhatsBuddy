import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsbuddy/core/constants/app_constants.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';

import '../../../core/presentation/widgets/action_button.dart';
import '../../../core/presentation/widgets/options_modal.dart';
import '../../../core/presentation/widgets/custom_text_field.dart';
import '../../contacts/data/contact_model.dart';
import '../../messaging/data/messaging_repository.dart';
import '../data/message_history_model.dart';
import '../../../core/presentation/bottom_nav.dart';
import '../data/country_model.dart';
import 'dial_code_modal.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  final TextEditingController _phoneController = TextEditingController();
  Country? _selectedCountry;
  List<Country> _countries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await Country.loadCountries();
      if (mounted) {
        final india = countries.firstWhere((c) => c.code == 'IN');
        setState(() {
          _countries = countries;
          _selectedCountry = india;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCountrySelector() {
    if (_countries.isEmpty || _isLoading) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DialCodeModal(
        countries: _countries,
        selectedCountry: _selectedCountry,
        onSelect: (country) {
          if (mounted) {
            setState(() => _selectedCountry = country);
          }
        },
      ),
    );
  }

  void _openWhatsAppChat() async {
    if (_selectedCountry == null) return;

    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    final cleanNumber = '${_selectedCountry!.dialCode}$phoneNumber';
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
    if (_selectedCountry == null) return;

    final nameController = TextEditingController();
    final phoneNumber =
        '${_selectedCountry!.dialCode}${_phoneController.text.trim()}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OptionsModal(
        title: 'Save\nTemporary Contact',
        inputController: nameController,
        inputHint: 'Enter contact name...',
        inputIcon: Icon(
          Icons.person_outline,
          size: 20,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white54
              : Colors.grey[600],
        ),
        options: [
          OptionItem(
            icon: Icon(
              Icons.close,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[900],
            ),
            label: 'Cancel',
            onTap: () => Navigator.pop(context),
          ),
          OptionItem(
            icon: Icon(
              Icons.check,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[900],
            ),
            label: 'Save',
            onTap: () {
              if (nameController.text.isNotEmpty && phoneNumber.isNotEmpty) {
                Hive.box<Contact>('contacts').add(Contact(
                  name: nameController.text,
                  number: phoneNumber,
                  createdAt: DateTime.now(),
                ));
                Navigator.pop(context);
                ref.read(navIndexProvider.notifier).state = 1;
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Icon
              SvgPicture.asset(
                'assets/icons/whatsapp_line.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  Colors.green[400]!,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 40),
              // Country Code Selector
              GestureDetector(
                onTap: _showCountrySelector,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    shape: SquircleBorder(radius: BorderRadius.circular(24)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        )
                      else if (_selectedCountry != null)
                        Text(
                          '${_selectedCountry!.dialCode} (${_selectedCountry!.name})',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.grey[800],
                            fontFamily: 'Geist',
                          ),
                        )
                      else
                        Text(
                          'Select Country',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark ? Colors.white54 : Colors.grey[400],
                            fontFamily: 'Geist',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Phone Input
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[800],
                    fontFamily: 'GeistMono',
                  ),
                  hintText: 'Enter phone number...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[400],
                    fontFamily: 'Geist',
                  ),
                  prefixIcon: SvgPicture.asset(
                    'assets/icons/phone_call_line.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white70 : Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionButton(
                    icon: Icons.schedule,
                    label: 'Start Chat',
                    onPressed: _openWhatsAppChat,
                  ),
                  const SizedBox(width: 16),
                  ActionButton(
                    icon: Icons.save_outlined,
                    label: 'Save\nTemporarily',
                    onPressed: () => _showSaveContactModal(context),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildHistorySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<List<MessageHistory>>(
      future: MessagingRepository.getHistory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/history_line.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.grey[900]!,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[900],
                    fontFamily: 'Geist',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final history = snapshot.data![index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: ShapeDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    shape: SquircleBorder(radius: BorderRadius.circular(24)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openWhatsAppDirectly(history.phoneNumber),
                      customBorder:
                          SquircleBorder(radius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/chat_3_line.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                isDark ? Colors.white70 : Colors.grey[600]!,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    history.phoneNumber,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark ? Colors.white : Colors.black,
                                      fontFamily: 'GeistMono',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat('hh:mm a').format(history.timestamp)} on ${DateFormat('dd-MM-yyyy').format(history.timestamp)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.grey[500],
                                      fontFamily: 'Geist',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark ? Colors.white54 : Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await MessagingRepository.clearHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('History cleared')),
                  );
                  if (mounted) setState(() {});
                },
                icon: SvgPicture.asset(
                  'assets/icons/delete_2_line.svg',
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    Colors.red[300]!,
                    BlendMode.srcIn,
                  ),
                ),
                label: Text(
                  'Delete History',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: 16,
                    fontFamily: 'Geist',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
