import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:streetcams_flutter/blocs/camera_bloc.dart';
import 'package:streetcams_flutter/widgets/map_widget.dart';

import '../constants.dart';
import '../entities/camera.dart';
import '../widgets/action_bar.dart';
import '../widgets/camera_list_view.dart';
import '../widgets/neighbourhood_search_bar.dart';
import '../widgets/search_text_field.dart';
import 'camera_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();
    final TextEditingController textEditingController = TextEditingController();

    void moveToListPosition(int index) {
      itemScrollController.jumpTo(index: index);
    }

    void showCameras(List<Camera> cameras, {shuffle = false}) {
      if (cameras.isNotEmpty) {
        Navigator.pushNamed(
          context,
          CameraPage.routeName,
          arguments: [cameras, shuffle],
        );
      }
    }

    void showAbout(BuildContext context) async {
      var packageInfo = await PackageInfo.fromPlatform();
      if (context.mounted) {
        showAboutDialog(
          context: context,
          applicationName: AppLocalizations.of(context)!.appName,
          applicationVersion: 'Version ${packageInfo.version}',
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
                ? Colors.transparent
                : Constants.accentColour,
            title: BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                switch (state.searchMode) {
                  case SearchMode.camera:
                    int count =
                        context.read<CameraBloc>().state.allCameras.length;
                    return SearchTextField(
                      controller: textEditingController,
                      hintText:
                          AppLocalizations.of(context)!.searchCameras(count),
                      searchMode: SearchMode.camera,
                    );
                  case SearchMode.neighbourhood:
                    return NeighbourhoodSearchBar();
                  case SearchMode.none:
                  default:
                    return GestureDetector(
                      child: Text(state.selectedCameras.isEmpty
                          ? AppLocalizations.of(context)!.appName
                          : '${state.selectedCameras.length} selected'),
                      onTap: () => moveToListPosition(0),
                    );
                }
                //searchMode is SearchMode.neighbourhood
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
                  return IndexedStack(
                    index: context.read<CameraBloc>().state.showList ? 0 : 1,
                    children: [
                      CameraListView(
                        itemScrollController: itemScrollController,
                        cameras: state.displayedCameras,
                        onTapped: (camera) => showCameras([camera]),
                      ),
                      MapWidget(
                        cameras: state.displayedCameras,
                        onTapped: (camera) => showCameras([camera]),
                      ),
                    ],
                  );
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
