import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:streetcams_flutter/widgets/search_text_field.dart';

import '../blocs/camera_bloc.dart';
import '../entities/neighbourhood.dart';

class NeighbourhoodSearchBar extends StatelessWidget {

  const NeighbourhoodSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    List<Neighbourhood> neighbourhoods =
        context.read<CameraBloc>().neighbourhoods;
    return Autocomplete<String>(
      optionsBuilder: (value) => getAutoCompleteOptions(value, neighbourhoods),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return SearchTextField(
          focusNode: focusNode,
          controller: controller,
          hintText: AppLocalizations.of(context)!
              .searchNeighbourhoods(neighbourhoods.length),
          searchMode: SearchMode.neighbourhood,
        );
        return TextField(
          focusNode: focusNode,
          controller: controller,
          textAlignVertical: TextAlignVertical.center,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            context.read<CameraBloc>().add(
                  SearchCameras(
                    searchMode: SearchMode.neighbourhood,
                    query: value,
                  ),
                );
          },
          decoration: InputDecoration(
            icon: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {},
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => controller.clear(),
                  )
                : null,
            hintText: AppLocalizations.of(context)!
                .searchNeighbourhoods(neighbourhoods.length),
          ),
        );
      },
    );
  }

  Iterable<String> getAutoCompleteOptions(
    TextEditingValue value,
    List<Neighbourhood> neighbourhoods,
  ) {
    if (value.text.isEmpty) {
      return [];
    }
    return neighbourhoods.map((n) => n.name).where(
      (name) {
        return name.toLowerCase().contains(value.text.trim().toLowerCase());
      },
    );
  }
}
