import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/camera_bloc.dart';

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
    clear() {
      controller.clear();
    }

    back() {
      clear();
      context
          .read<CameraBloc>()
          .add(SearchCameras(searchMode: SearchMode.none));
    }

    return TextField(
      focusNode: focusNode,
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        context.read<CameraBloc>().add(
              SearchCameras(
                searchMode: searchMode,
                query: value,
              ),
            );
      },
      decoration: InputDecoration(
        icon: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: back,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: clear,
              )
            : null,
        hintText: hintText,
      ),
    );
  }
}
