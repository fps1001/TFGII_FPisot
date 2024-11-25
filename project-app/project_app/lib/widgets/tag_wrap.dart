// FILE: widgets/tag_wrap.dart
import 'package:flutter/material.dart';
import 'package:project_app/helpers/icon_helpers.dart'; // Importar icon_helpers.dart

class TagWrap extends StatelessWidget {
  final Map<String, bool> selectedPreferences;
  final Function(String) onTagSelected;

  const TagWrap({
    super.key,
    required this.selectedPreferences,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: userPreferences.keys.map((String key) {
        final preference = userPreferences[key];
        final bool isSelected = selectedPreferences[key] ?? false;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                preference?['icon'],
                size: 20.0,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6.0),
              Text(
                key,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(
              color: isSelected ? preference!['color'] : Colors.grey.shade400,
            ),
          ),
          selectedColor: preference!['color'],
          backgroundColor: isSelected
              ? preference['color']
              : preference['color']!.withOpacity(0.1),
          elevation: isSelected ? 4.0 : 1.0,
          shadowColor: Colors.grey.shade300,
          selected: isSelected,
          onSelected: (bool selected) {
            onTagSelected(key);
          },
        );
      }).toList(),
    );
  }
}
