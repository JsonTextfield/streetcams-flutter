import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/widgets/map_widget.dart';

import '../constants.dart';
import '../entities/camera.dart';
import '../widgets/action_bar.dart';
import '../widgets/camera_list_view.dart';
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
            actions: const [ActionBar()],
            backgroundColor: state.selectedCameras.isEmpty
                ? Theme.of(context).appBarTheme.backgroundColor
                : Constants.accentColour,
            title: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                switch (state.searchMode) {
                  case SearchMode.camera:
                    return SearchTextField(
                      controller: textEditingController,
                      hintText: AppLocalizations.of(context)!
                          .searchCameras(state.allCameras.length),
                      searchMode: SearchMode.camera,
                    );
                  case SearchMode.neighbourhood:
                    return const NeighbourhoodSearchBar();
                  case SearchMode.none:
                  default:
                    String title = '';
                    switch (state.filterMode) {
                      case FilterMode.favourite:
                        title = AppLocalizations.of(context)!.favourites;
                        break;
                      case FilterMode.hidden:
                        title = AppLocalizations.of(context)!.hidden;
                        break;
                      case FilterMode.visible:
                      default:
                        title = state.selectedCameras.isEmpty
                            ? AppLocalizations.of(context)!.appName
                            : AppLocalizations.of(context)!
                                .selectedCameras(state.selectedCameras.length);
                        break;
                    }
                    return GestureDetector(
                      child: Text(title),
                      onTap: () => _moveToListPosition(0),
                    );
                }
              },
            ),
          ),
          body: BlocBuilder<CameraBloc, CameraState>(
            builder: (context, state) {
              switch (state.status) {
                case CameraStatus.failure:
                  return Center(
                    child: Text(AppLocalizations.of(context)!.error),
                  );
                case CameraStatus.success:
                  if (state.showList) {
                    return Row(children: [
                      if (state.showSectionIndex)
                        Flexible(
                          flex: 0,
                          child: SectionIndex(
                            data: state.visibleCameras
                                .map((cam) => cam.sortableName)
                                .toList(),
                            callback: _moveToListPosition,
                          ),
                        ),
                      Expanded(
                        child: CameraListView(
                          itemScrollController: itemScrollController,
                          cameras: state.displayedCameras,
                          onTapped: (camera) => showCameras([camera]),
                        ),
                      ),
                    ]);
                  }
                  return MapWidget(cameras: state.displayedCameras);
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
