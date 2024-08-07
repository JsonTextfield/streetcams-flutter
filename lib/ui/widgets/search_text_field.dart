import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../blocs/camera_bloc.dart';

class SearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final SearchMode searchMode;

  const SearchTextField({
    super.key,
    this.hintText = '',
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

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        if (controller.text.isEmpty &&
            MediaQuery.orientationOf(context) == Orientation.portrait)
          TextScroll(
            hintText,
            intervalSpaces: 10,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
            delayBefore: const Duration(milliseconds: 2000),
            pauseBetween: const Duration(milliseconds: 2000),
            velocity: const Velocity(pixelsPerSecond: Offset(30, 0)),
          ),
        TextField(
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
          focusNode: focusNode,
          controller: controller,
          //textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.done,
          onChanged: search,
          decoration: InputDecoration(
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: clear,
                    tooltip: context.translation.clear,
                  )
                : null,
            hintText: MediaQuery.orientationOf(context) == Orientation.landscape
                ? hintText
                : '',
            hintStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.normal,
            ),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        )
      ],
    );
  }
}
