import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    back() {
      controller.clear();
      context
          .read<CameraBloc>()
          .add(SearchCameras(searchMode: SearchMode.none));
    }

    search(value) {
      context
          .read<CameraBloc>()
          .add(SearchCameras(searchMode: searchMode, query: value));
    }

    return TextField(
      style: const TextStyle(color: Colors.white),
      focusNode: focusNode,
      controller: controller,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      onChanged: search,
      decoration: InputDecoration(
        icon: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: back,
          tooltip: AppLocalizations.of(context)!.back,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, color: Colors.white),
                onPressed: clear,
                tooltip: AppLocalizations.of(context)!.clear,
              )
            : null,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
