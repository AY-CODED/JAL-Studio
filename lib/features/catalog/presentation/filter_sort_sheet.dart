import 'package:flutter/material.dart';

import '../../../core/theme/store_colors.dart';
import '../data/catalog_repository.dart';

class FilterSortSheet extends StatefulWidget {
  const FilterSortSheet({
    super.key,
    this.initial = const CatalogQuery(),
    this.brands = const [],
    this.sizes = const [],
    this.colors = const [],
    this.styles = const [],
    this.maximumPriceKobo = 50000000,
  });

  final CatalogQuery initial;
  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;
  final List<String> styles;
  final int maximumPriceKobo;

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late String _sort = widget.initial.sort;
  late String? _category = widget.initial.category;
  late String? _brand = widget.initial.brand;
  late String? _size = widget.initial.size;
  late String? _color = widget.initial.color;
  late String? _style = widget.initial.style;
  late RangeValues _price = RangeValues(
    (widget.initial.minPriceKobo ?? 0).toDouble(),
    (widget.initial.maxPriceKobo ?? widget.maximumPriceKobo).toDouble(),
  );

  @override
  Widget build(BuildContext context) {
    final maxPrice = widget.maximumPriceKobo.toDouble() < 1
        ? 1.0
        : widget.maximumPriceKobo.toDouble();
    final hasPriceFilter = _price.start > 0 || _price.end < maxPrice;
    return SafeArea(
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
                  TextButton(
                    onPressed: () => setState(() {
                      _category = null;
                      _brand = null;
                      _size = null;
                      _color = null;
                      _style = null;
                      _price = RangeValues(0, maxPrice);
                      _sort = 'recommended';
                    }),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const Divider(),
              const Text(
                'SORT BY',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final choice in const [
                    ('recommended', 'Recommended'),
                    ('newest', 'Newest first'),
                    ('price_asc', 'Price: low to high'),
                    ('price_desc', 'Price: high to low'),
                  ])
                    ChoiceChip(
                      label: Text(choice.$2),
                      selected: _sort == choice.$1,
                      onSelected: (_) => setState(() => _sort = choice.$1),
                    ),
                ],
              ),
              _chipFilter(
                'Category',
                [
                  ('menswear', 'Men'),
                  ('womenswear', 'Women'),
                  ('accessories', 'Accessories'),
                  ('activewear', 'Activewear'),
                ],
                _category,
                (value) => setState(() => _category = value),
              ),
              if (widget.brands.isNotEmpty)
                _choiceFilter('Brand', widget.brands, _brand, (value) {
                  setState(() => _brand = value);
                }),
              if (widget.sizes.isNotEmpty)
                _chipFilter(
                  'Size',
                  widget.sizes.map((value) => (value, value)).toList(),
                  _size,
                  (value) => setState(() => _size = value),
                ),
              if (widget.colors.isNotEmpty)
                _chipFilter(
                  'Colour',
                  widget.colors.map((value) => (value, value)).toList(),
                  _color,
                  (value) => setState(() => _color = value),
                ),
              if (widget.styles.isNotEmpty)
                _chipFilter(
                  'Style',
                  widget.styles.map((value) => (value, value)).toList(),
                  _style,
                  (value) => setState(() => _style = value),
                ),
              const SizedBox(height: 8),
              const Text(
                'PRICE RANGE',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RangeSlider(
                min: 0.0,
                max: maxPrice,
                values: _price,
                labels: RangeLabels(
                  '₦${(_price.start / 100).round()}',
                  '₦${(_price.end / 100).round()}',
                ),
                onChanged: (value) => setState(() => _price = value),
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    CatalogQuery(
                      category: _category,
                      brand: _brand,
                      size: _size,
                      color: _color,
                      style: _style,
                      minPriceKobo: hasPriceFilter
                          ? _price.start.round()
                          : null,
                      maxPriceKobo: hasPriceFilter ? _price.end.round() : null,
                      sort: _sort,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: StoreColors.ink,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text('Apply filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _choiceFilter(
    String title,
    List<String> options,
    String? selected,
    ValueChanged<String?> onSelected,
  ) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: Text(title),
    children: [
      DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: InputDecoration(
          hintText: 'Any $title',
          border: const OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem(value: null, child: Text('Any')),
          ...options.map(
            (value) => DropdownMenuItem(value: value, child: Text(value)),
          ),
        ],
        onChanged: onSelected,
      ),
    ],
  );

  Widget _chipFilter(
    String title,
    List<(String, String)> options,
    String? selected,
    ValueChanged<String?> onSelected,
  ) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: Text(title),
    children: [
      Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Any'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          ...options.map(
            (option) => ChoiceChip(
              label: Text(option.$2),
              selected: selected == option.$1,
              onSelected: (_) =>
                  onSelected(selected == option.$1 ? null : option.$1),
            ),
          ),
        ],
      ),
    ],
  );
}
