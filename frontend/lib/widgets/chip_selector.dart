import 'package:flutter/material.dart';
import '../config/theme.dart';

class ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDark : AppColors.inputBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryDark : AppColors.inputBorder,
                width: 1.5,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.primaryDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
