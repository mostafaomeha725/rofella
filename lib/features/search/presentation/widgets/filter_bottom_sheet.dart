import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/utils/spacing.dart';

class FilterBottomSheet extends StatefulWidget {
  final double minPrice;
  final double maxPrice;
  final double globalMaxPrice;
  final String sortBy;
  final Function(double min, double max, String sort) onApply;

  const FilterBottomSheet({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.globalMaxPrice,
    required this.sortBy,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _currentMin;
  late double _currentMax;
  late String _currentSort;

  @override
  void initState() {
    super.initState();
    _currentMin = widget.minPrice;
    _currentMax = widget.maxPrice;
    _currentSort = widget.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          verticalSpacing(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تصفية النتائج', style: font18w700.copyWith(color: Colors.black87)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentMin = 0;
                    _currentMax = widget.globalMaxPrice;
                    _currentSort = 'newest';
                  });
                },
                child: Text('إعادة ضبط', style: font14w400.copyWith(color: const Color(0xFFC7433A))),
              ),
            ],
          ),
          const Divider(),
          verticalSpacing(16),

          // 1. Sort By
          Text('الترتيب حسب', style: font16w600.copyWith(color: Colors.black87)),
          verticalSpacing(8),
          Wrap(
            spacing: 8,
            children: [
              _buildChoiceChip('الأحدث', 'newest', _currentSort, (val) => setState(() => _currentSort = val)),
              _buildChoiceChip('الأرخص', 'lowest_price', _currentSort, (val) => setState(() => _currentSort = val)),
              _buildChoiceChip('الأغلى', 'highest_price', _currentSort, (val) => setState(() => _currentSort = val)),
            ],
          ),
          verticalSpacing(24),

          // 2. Price Range
          Text('نطاق السعر', style: font16w600.copyWith(color: Colors.black87)),
          verticalSpacing(8),
          RangeSlider(
            values: RangeValues(_currentMin, _currentMax),
            min: 0,
            max: widget.globalMaxPrice,
            divisions: widget.globalMaxPrice > 0 ? 100 : 1,
            activeColor: const Color(0xFF9E6566),
            inactiveColor: Colors.grey[200],
            labels: RangeLabels('${_currentMin.toInt()} EGP', '${_currentMax.toInt()} EGP'),
            onChanged: (values) {
              setState(() {
                _currentMin = values.start;
                _currentMax = values.end;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentMin.toInt()} EGP', style: font14w400.copyWith(color: Colors.grey[600])),
              Text('${_currentMax.toInt()} EGP', style: font14w400.copyWith(color: Colors.grey[600])),
            ],
          ),
          verticalSpacing(24),

          verticalSpacing(32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E6566),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                widget.onApply(_currentMin, _currentMax, _currentSort);
                Navigator.pop(context);
              },
              child: Text('تطبيق', style: font16w600.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, String groupValue, Function(String) onSelect) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) onSelect(value);
      },
      selectedColor: const Color(0xFF9E6566),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
      backgroundColor: Colors.grey[100],
    );
  }
}
