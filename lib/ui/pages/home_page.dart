import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/l10n/translation.dart';
import 'package:streetcams_flutter/ui/widgets/flutter_map_widget.dart';

import '../../blocs/camera_bloc.dart';
import '../../constants.dart';
import '../../entities/camera.dart';
import '../widgets/camera_gallery_view.dart';
import '../widgets/camera_list_view.dart';
import '../widgets/map_widget.dart';
import '../widgets/menus/action_bar.dart';
import '../widgets/neighbourhood_search_bar.dart';
import '../widgets/search_text_field.dart';
import '../widgets/section_index.dart';
import 'camera_page.dart';

class HomePage extends StatelessWidget {
  final ItemScrollController itemScrollController = ItemScrollController();
  final TextEditingController textEditingController = TextEditingController();

  HomePage({super.key});

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
            backgroundColor: state.selectedCameras.isEmpty
                ? Theme.of(context).appBarTheme.backgroundColor
                : Constants.accentColour,
            titleSpacing: 0.0,
            title: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                if (state.selectedCameras.isEmpty) {
                  switch (state.searchMode) {
                    case SearchMode.camera:
                      return SearchTextField(
                        controller: textEditingController,
                        hintText: context.translation
                            .searchCameras(state.displayedCameras.length),
                        searchMode: SearchMode.camera,
                      );
                    case SearchMode.neighbourhood:
                      return NeighbourhoodSearchBar(
                        hintText: textEditingController.text.isEmpty
                            ? context.translation.searchNeighbourhoods(
                                state.neighbourhoods.length)
                            : '',
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
                return InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(title),
                  ),
                  onTap: () => _moveToListPosition(0),
                );
              },
            ),
          ),
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              switch (state.status) {
                case CameraStatus.failure:
                  return Center(
                    child: Text(context.translation.error),
                  );
                case CameraStatus.success:
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
                        );
                      }
                      return MapWidget(
                        cameras: state.displayedCameras,
                        onItemClick: onClick,
                        onItemLongClick: onLongClick,
                      );
                    case ViewMode.gallery:
                      return CameraGalleryView(
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
                              callback: _moveToListPosition,
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
                case CameraStatus.initial:
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
