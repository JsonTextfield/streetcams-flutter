import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/ui/widgets/camera_gallery_view.dart';
import 'package:streetcams_flutter/ui/widgets/camera_list_view.dart';
import 'package:streetcams_flutter/ui/widgets/flutter_map_widget.dart';
import 'package:streetcams_flutter/ui/widgets/map_widget.dart';
import 'package:streetcams_flutter/ui/widgets/menus/action_bar.dart';
import 'package:streetcams_flutter/ui/widgets/neighbourhood_search_bar.dart';
import 'package:streetcams_flutter/ui/widgets/search_text_field.dart';
import 'package:streetcams_flutter/ui/widgets/section_index.dart';

import 'camera_page.dart';

class HomePage extends StatelessWidget {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController;
  final MapController flutterMapController = MapController();
  late final GoogleMapController mapController;

  HomePage({
    super.key,
    required this.textEditingController,
  });

  void _moveToListPosition(int index) {
    itemScrollController.jumpTo(index: index);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('building home page');

    void showCameras(List<Camera> cameras, {shuffle = false}) {
      if (cameras.isNotEmpty) {
        Navigator.pushNamed(
          context,
          CameraPage.routeName,
          arguments: [cameras, shuffle],
        );
      }
    }

    void onClear(SearchMode searchMode) {
      textEditingController.clear();
      context.read<CameraBloc>().add(SearchCameras(searchMode: searchMode));
    }

    void onTextChanged(String value, SearchMode searchMode) {
      context.read<CameraBloc>().add(
        SearchCameras(
          searchMode: searchMode,
          searchText: value,
        ),
      );
    }

    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            leading: state.showBackButton
                ? IconButton(
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      context.read<CameraBloc>().add(ResetFilters());
                    },
                    tooltip: context.translation.back,
                  )
                : null,
            actions: const [ActionBar()],
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surface,
            shadowColor: Theme.of(context).colorScheme.shadow,
            elevation: 5.0,
            title: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                if (state.selectedCameras.isEmpty) {
                  switch (state.searchMode) {
                    case SearchMode.camera:
                      return SearchTextField(
                        controller: textEditingController,
                        hintText: context.translation
                            .searchCameras(state.displayedCameras.length),
                        onClear: () => onClear(SearchMode.camera),
                        onTextChanged: (value) => onTextChanged(value, SearchMode.camera),
                      );
                    case SearchMode.neighbourhood:
                      return NeighbourhoodSearchBar(
                        hintText: textEditingController.text.isEmpty
                            ? context.translation.searchNeighbourhoods(
                                state.neighbourhoods.length)
                            : '',
                        onClear: () => onClear(SearchMode.neighbourhood),
                        onTextChanged: (value) => onTextChanged(value, SearchMode.neighbourhood),
                      );
                    case SearchMode.none:
                    default:
                      break;
                  }
                }

                String title = state.selectedCameras.isNotEmpty
                    ? context.translation
                        .selectedCameras(state.selectedCameras.length)
                    : switch (state.filterMode) {
                        FilterMode.favourite => context.translation.favourites,
                        FilterMode.hidden => context.translation.hidden,
                        FilterMode.visible => context.translation.appName,
                      };
                titleTapped() async {
                  switch (state.viewMode) {
                    case ViewMode.list:
                      _moveToListPosition(0);
                      break;
                    case ViewMode.gallery:
                      scrollController.jumpTo(0);
                      break;
                    case ViewMode.map:
                      double minZoom = switch (state.city) {
                        City.ottawa ||
                        City.toronto ||
                        City.calgary ||
                        City.vancouver ||
                        City.surrey =>
                          10,
                        _ => 5,
                      };
                      if (defaultTargetPlatform == TargetPlatform.windows) {
                        flutterMapController.move(
                          flutterMapController.camera.center,
                          minZoom,
                        );
                      } //
                      else {
                        CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(
                          (await mapController.getVisibleRegion()).centre,
                          minZoom,
                        );
                        mapController.animateCamera(cameraUpdate);
                      }
                      break;
                  }
                }

                return InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: titleTapped,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(title),
                  ),
                );
              },
            ),
          ),
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              switch (state.uiState) {
                case UIState.failure:
                  return Center(
                    child: Text(context.translation.error),
                  );
                case UIState.success:
                  onClick(Camera camera) {
                    if (state.selectedCameras.isEmpty) {
                      showCameras([camera]);
                    } else {
                      context
                          .read<CameraBloc>()
                          .add(SelectCamera(camera: camera));
                    }
                  }
                  onLongClick(Camera camera) {
                    context
                        .read<CameraBloc>()
                        .add(SelectCamera(camera: camera));
                  }
                  switch (state.viewMode) {
                    case ViewMode.map:
                      if (defaultTargetPlatform == TargetPlatform.windows &&
                          !kIsWeb) {
                        return FlutterMapWidget(
                          cameras: state.displayedCameras,
                          onItemClick: onClick,
                          onItemLongClick: onLongClick,
                          controller: flutterMapController,
                        );
                      }
                      return MapWidget(
                        cameras: state.displayedCameras,
                        onItemClick: onClick,
                        onItemLongClick: onLongClick,
                        onMapCreated: (gmc) => mapController = gmc,
                      );
                    case ViewMode.gallery:
                      return CameraGalleryView(
                        scrollController: scrollController,
                        cameras: state.displayedCameras,
                        onItemClick: onClick,
                        onItemLongClick: onLongClick,
                      );
                    case ViewMode.list:
                    default:
                      return Row(children: [
                        if (state.showSectionIndex)
                          Flexible(
                            flex: 0,
                            child: SectionIndex(
                              data: state.displayedCameras
                                  .map((cam) => cam.sortableName[0])
                                  .toList(),
                              onIndexSelected: _moveToListPosition,
                            ),
                          ),
                        Expanded(
                          child: CameraListView(
                            itemScrollController: itemScrollController,
                            cameras: state.displayedCameras,
                            onItemClick: onClick,
                            onItemLongClick: onLongClick,
                          ),
                        ),
                      ]);
                  }
                case UIState.loading:
                default:
                  return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        );
      },
    );
  }
}
