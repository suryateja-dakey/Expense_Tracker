import 'package:flutter/material.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CustomDropdownField extends StatelessWidget {
  final String hintText;
  final List<String> items;
  final String? selectedItem;
  final dynamic onChanged;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomDropdown<String>(
      hintText: hintText,
      items: items,
      initialItem: selectedItem,
      onChanged: onChanged,
      decoration: CustomDropdownDecoration(
        closedFillColor: theme.cardColor,
        expandedFillColor: theme.cardColor,
        closedBorder: Border.all(color: Colors.grey.shade700),
        expandedBorder: Border.all(color: theme.primaryColor),
        closedBorderRadius: BorderRadius.circular(12),
        expandedBorderRadius: BorderRadius.circular(12),
      ),
      listItemBuilder: (context, item, isSelected, onTap) {
        return ListTile(
          title: Text(
            item,
            style: TextStyle(
              color: isSelected ? theme.colorScheme.secondary : Colors.white,
            ),
          ),
          onTap: onTap,
        );
      },
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2);
  }
}
