import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/ui/widgets/search_text_field.dart';

import '../../blocs/camera_bloc.dart';

class NeighbourhoodSearchBar extends StatelessWidget {
  const NeighbourhoodSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('building neighbourhood search bar');
    List<String> neighbourhoods = context
        .read<CameraBloc>()
        .state
        .allCameras
        .map((camera) => camera.neighbourhood)
        .toSet()
        .toList();

    return Autocomplete<String>(
      onSelected: (value) => context.read<CameraBloc>().add(
            SearchCameras(searchMode: SearchMode.neighbourhood, query: value),
          ),
      optionsBuilder: (value) => getAutoCompleteOptions(value, neighbourhoods),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return SearchTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: AppLocalizations.of(context)!
              .searchNeighbourhoods(neighbourhoods.length),
          searchMode: SearchMode.neighbourhood,
        );
      },
    );
  }

  Iterable<String> getAutoCompleteOptions(
    TextEditingValue value,
    List<String> options,
  ) {
    return value.text.isEmpty
        ? []
        : options.where((String s) => s.containsIgnoreCase(value.text.trim()));
  }
}
