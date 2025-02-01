import 'package:flutter/material.dart';
import '../data/country_model.dart';

class CountrySelector extends StatefulWidget {
  final Function(Country) onSelect;
  final List<Country> countries;
  final Country? selectedCountry;

  const CountrySelector({
    super.key,
    required this.onSelect,
    required this.countries,
    this.selectedCountry,
  });

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  late List<Country> filteredCountries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredCountries = List.from(widget.countries);
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCountries = List.from(widget.countries);
      } else {
        filteredCountries = widget.countries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.dialCode.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Dial Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterCountries,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCountries.length,
              itemBuilder: (context, index) {
                final country = filteredCountries[index];
                final isSelected = widget.selectedCountry?.code == country.code;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onSelect(country);
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: isSelected
                          ? (isDark ? Colors.grey[800] : Colors.grey[50])
                          : null,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 64,
                            child: Text(
                              country.dialCode,
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDark ? Colors.white70 : Colors.grey[600],
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              country.name,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white : Colors.grey[900],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check,
                                color: Colors.green[400], size: 20),
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
