import 'package:flutter/material.dart';
import 'dart:ui';
import '../data/country_model.dart';

class DialCodeModal extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final Function(Country) onSelect;

  const DialCodeModal({
    super.key,
    required this.countries,
    this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<DialCodeModal> createState() => _DialCodeModalState();
}

class _DialCodeModalState extends State<DialCodeModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredCountries = widget.countries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.dialCode.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = MediaQuery.of(context).size.height - keyboardHeight;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        margin: EdgeInsets.fromLTRB(16, 0, 16, keyboardHeight + 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select Country\nDial Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: isDark ? Colors.white : Colors.black,
                fontFamily: 'Geist',
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    Icons.search,
                    size: 20,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontFamily: 'Geist',
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey[400],
                          fontSize: 16,
                          fontFamily: 'Geist',
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: availableHeight * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredCountries.length,
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onSelect(country);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 56,
                              child: Text(
                                country.dialCode,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.grey[600],
                                  fontSize: 14,
                                  fontFamily: 'GeistMono',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                country.name,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Geist',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
