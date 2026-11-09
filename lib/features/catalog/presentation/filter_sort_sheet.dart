import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';

class FilterSortSheet extends StatefulWidget {
  const FilterSortSheet({super.key});
  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  String _sort = 'Recommended';
  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: StoreColors.line,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & sort',
                  style: TextStyle(fontSize: 28, fontFamily: 'serif'),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const Text(
              'SORT BY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            ...[
              'Recommended',
              'Newest first',
              'Price: low to high',
              'Price: high to low',
            ].map(
              (value) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(value, style: const TextStyle(fontSize: 13)),
                trailing: Icon(
                  _sort == value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: StoreColors.ink,
                ),
                onTap: () => setState(() => _sort = value),
              ),
            ),
            const Divider(),
            ...['Category', 'Size', 'Colour', 'Price'].map(
              (value) => ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(value, style: const TextStyle(fontSize: 14)),
                children: [
                  Wrap(
                    spacing: 8,
                    children: ['S', 'M', 'L', 'XL']
                        .map(
                          (size) => ChoiceChip(
                            label: Text(size),
                            selected: false,
                            onSelected: (_) {},
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: StoreColors.ink,
                  padding: const EdgeInsets.all(15),
                ),
                child: const Text('Show 6 pieces'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
