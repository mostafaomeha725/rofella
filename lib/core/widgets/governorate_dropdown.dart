import 'package:flutter/material.dart';
import 'package:shop/core/theme/styles.dart';
import 'package:shop/core/widgets/custom_text.dart';
import 'package:shop/core/widgets/app_form_field.dart';

// ── All Egyptian Governorates ────────────────────────────────────────────────
const List<GovernorateDropdownItem> kEgyptGovernorates = [
  GovernorateDropdownItem(id: 1, name: 'القاهرة'),
  GovernorateDropdownItem(id: 2, name: 'الجيزة'),
  GovernorateDropdownItem(id: 3, name: 'الإسكندرية'),
  GovernorateDropdownItem(id: 4, name: 'الدقهلية'),
  GovernorateDropdownItem(id: 5, name: 'الشرقية'),
  GovernorateDropdownItem(id: 6, name: 'القليوبية'),
  GovernorateDropdownItem(id: 7, name: 'المنوفية'),
  GovernorateDropdownItem(id: 8, name: 'الغربية'),
  GovernorateDropdownItem(id: 9, name: 'كفر الشيخ'),
  GovernorateDropdownItem(id: 10, name: 'البحيرة'),
  GovernorateDropdownItem(id: 11, name: 'الإسماعيلية'),
  GovernorateDropdownItem(id: 12, name: 'بورسعيد'),
  GovernorateDropdownItem(id: 13, name: 'السويس'),
  GovernorateDropdownItem(id: 14, name: 'شمال سيناء'),
  GovernorateDropdownItem(id: 15, name: 'جنوب سيناء'),
  GovernorateDropdownItem(id: 16, name: 'الفيوم'),
  GovernorateDropdownItem(id: 17, name: 'بني سويف'),
  GovernorateDropdownItem(id: 18, name: 'المنيا'),
  GovernorateDropdownItem(id: 19, name: 'أسيوط'),
  GovernorateDropdownItem(id: 20, name: 'سوهاج'),
  GovernorateDropdownItem(id: 21, name: 'قنا'),
  GovernorateDropdownItem(id: 22, name: 'الأقصر'),
  GovernorateDropdownItem(id: 23, name: 'أسوان'),
  GovernorateDropdownItem(id: 24, name: 'البحر الأحمر'),
  GovernorateDropdownItem(id: 25, name: 'الوادي الجديد'),
  GovernorateDropdownItem(id: 26, name: 'مطروح'),
  GovernorateDropdownItem(id: 27, name: 'دمياط'),
];

class GovernorateDropdown extends StatefulWidget {
  final String? initialValue;
  final List<GovernorateDropdownItem> governorates;
  final bool isLoading;
  final void Function(String?)? onChanged;
  final void Function(int?)? onChangedId;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;

  const GovernorateDropdown({
    super.key,
    this.initialValue,
    this.governorates = kEgyptGovernorates,
    this.isLoading = false,
    this.onChanged,
    this.onChangedId,
    this.hintText,
    this.labelText,
    this.validator,
  });

  @override
  State<GovernorateDropdown> createState() => _GovernorateDropdownState();
}

class _GovernorateDropdownState extends State<GovernorateDropdown> {
  late TextEditingController _controller;
  String? selectedGovernorate;

  @override
  void initState() {
    super.initState();
    selectedGovernorate = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _selectedGovernorateId() {
    if (selectedGovernorate == null) return null;
    for (final gov in widget.governorates) {
      if (gov.name == selectedGovernorate) return gov.id;
    }
    return null;
  }

  void _showGovernorateBottomSheet() {
    if (widget.isLoading) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _GovernorateBottomSheet(
          hintText: widget.hintText,
          governorates: widget.governorates,
          selectedGovernorate: selectedGovernorate,
          onSelected: (item) {
            setState(() {
              selectedGovernorate = item.name;
              _controller.text = item.name;
            });
            widget.onChanged?.call(item.name);
            widget.onChangedId?.call(_selectedGovernorateId());
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          AppText(
            widget.labelText!,
            style: font14w500.copyWith(color: const Color(0xff364153)),
          ),
          const SizedBox(height: 8),
        ],
        AppFormField(
          controller: _controller,
          hintText: widget.isLoading
              ? 'جاري التحميل...'
              : widget.hintText ?? 'اختر المحافظة',
          readOnly: true,
          onTap: _showGovernorateBottomSheet,
          suffixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
          validator: widget.validator,
        ),
      ],
    );
  }
}

class _GovernorateBottomSheet extends StatefulWidget {
  final String? hintText;
  final List<GovernorateDropdownItem> governorates;
  final String? selectedGovernorate;
  final Function(GovernorateDropdownItem) onSelected;

  const _GovernorateBottomSheet({
    this.hintText,
    required this.governorates,
    this.selectedGovernorate,
    required this.onSelected,
  });

  @override
  State<_GovernorateBottomSheet> createState() => _GovernorateBottomSheetState();
}

class _GovernorateBottomSheetState extends State<_GovernorateBottomSheet> {
  late List<GovernorateDropdownItem> _filteredList;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredList = widget.governorates;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filteredList = widget.governorates
          .where((gov) => gov.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    widget.hintText ?? 'اختر المحافظة',
                    style: font18w700.copyWith(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                controller: _searchCtrl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث عن محافظة...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            // List
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: _filteredList.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF5F5F5),
                ),
                itemBuilder: (context, index) {
                  final item = _filteredList[index];
                  final isSelected = item.name == widget.selectedGovernorate;

                  return ListTile(
                    title: AppText(
                      item.name,
                      style: font16w700.copyWith(
                        color: isSelected ? Colors.blue[700] : Colors.black87,
                      ),
                      alignment: AlignmentDirectional.centerStart,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue[700])
                        : null,
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}


class GovernorateDropdownItem {
  final int id;
  final String name;

  const GovernorateDropdownItem({required this.id, required this.name});
}
