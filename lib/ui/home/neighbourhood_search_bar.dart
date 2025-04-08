import 'package:flutter/material.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/ui/home/search_text_field.dart';

class NeighbourhoodSearchBar extends StatelessWidget {
  final String hintText;
  final List<String> data;
  final void Function() onClear;
  final void Function(String) onTextChanged;

  const NeighbourhoodSearchBar({
    super.key,
    this.hintText = '',
    this.data = const [],
    required this.onClear,
    required this.onTextChanged,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building neighbourhood search bar');
    return Autocomplete<String>(
      onSelected: onTextChanged,
      optionsBuilder: (value) {
        return value.text.isEmpty
            ? []
            : data.where((String s) => s.containsIgnoreCase(value.text.trim()));
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return SearchTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: hintText,
          onClear: () {
            controller.clear();
            onClear();
          },
          onTextChanged: onTextChanged,
        );
      },
    );
  }
}
