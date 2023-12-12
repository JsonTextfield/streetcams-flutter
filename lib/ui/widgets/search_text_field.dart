import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streetcams_flutter/l10n/translation.dart';

import '../../blocs/camera_bloc.dart';

class SearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final SearchMode searchMode;

  const SearchTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.searchMode,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('building search bar');
    clear() {
      controller.clear();
      context.read<CameraBloc>().add(SearchCameras(searchMode: searchMode));
    }

    search(value) {
      context.read<CameraBloc>().add(
            SearchCameras(
              searchMode: searchMode,
              searchText: value,
            ),
          );
    }

    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: Colors.white,
      focusNode: focusNode,
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.done,
      onChanged: search,
      decoration: InputDecoration(
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.white),
                onPressed: clear,
                tooltip: context.translation.clear,
              )
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
