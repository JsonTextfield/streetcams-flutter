import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:streetcams_flutter/blocs/camera_state.dart';
import 'package:streetcams_flutter/entities/bilingual_object.dart';
import 'package:streetcams_flutter/entities/camera.dart';
import 'package:streetcams_flutter/entities/city.dart';
import 'package:streetcams_flutter/entities/latlon.dart';

void main() {
  test('test initial state', () {
    CameraState state = const CameraState();
    expect(state, const CameraState());
    expect(state.viewMode, ViewMode.gallery);
    expect(state.sortMode, SortMode.name);
    expect(state.filterMode, FilterMode.visible);
    expect(state.city, City.ottawa);
    expect(state.searchMode, SearchMode.none);
    expect(state.searchText, '');
    expect(state.status, CameraStatus.initial);
    expect(state.allCameras, <Camera>[]);
    expect(state.displayedCameras, <Camera>[]);

    // read-only properties
    expect(state.neighbourhoods, <String>[]);
    expect(state.visibleCameras, <Camera>[]);
    expect(state.hiddenCameras, <Camera>[]);
    expect(state.favouriteCameras, <Camera>[]);
    expect(state.selectedCameras, <Camera>[]);
    expect(state.showSectionIndex, false);
    expect(state.showSearchNeighbourhood, false);
    expect(state.showBackButton, false);
  });

  test('test copyWith', () {
    CameraState state1 = const CameraState();
    CameraState state2 = state1.copyWith(
      status: CameraStatus.failure,
      searchMode: SearchMode.camera,
      searchText: 'hello world',
      viewMode: ViewMode.map,
      sortMode: SortMode.distance,
      filterMode: FilterMode.favourite,
      city: City.vancouver,
    );

    expect(state2 == state1, false);
    expect(state2.allCameras, <Camera>[]);
    expect(state2.displayedCameras, <Camera>[]);
    expect(state2.status, CameraStatus.failure);
    expect(state2.sortMode, SortMode.distance);
    expect(state2.searchMode, SearchMode.camera);
    expect(state2.searchText, 'hello world');
    expect(state2.filterMode, FilterMode.favourite);
    expect(state2.viewMode, ViewMode.map);
    expect(state2.lastUpdated, 0);
    expect(state2.city, City.vancouver);
  });

  test('test getDisplayedCameras', () {
    List<Camera> cameras = List.generate(100, (i) {
      return Camera(
        location: LatLon(
          lat: Random().nextDouble() * 90,
          lon: Random().nextDouble() * 180 - 90,
        ),
        city: City.vancouver,
        name: BilingualObject(
            en: i % 3 == 0
                ? 'hello'
                : i % 3 == 1
                    ? 'there'
                    : 'world'),
        neighbourhood: BilingualObject(
            en: i % 3 == 0
                ? 'town'
                : i % 3 == 1
                    ? 'borough'
                    : 'city'),
      )
        ..isVisible = Random().nextBool()
        ..isFavourite = Random().nextBool();
    });
    CameraState state = CameraState(allCameras: cameras);
    expect(
      state.getDisplayedCameras(),
      cameras.where((camera) => camera.isVisible).toList()
        ..sort((a, b) => a.sortableName.compareTo(b.sortableName)),
    );

    state = state.copyWith(
      searchMode: SearchMode.camera,
      searchText: 'l',
      filterMode: FilterMode.favourite,
      sortMode: SortMode.neighbourhood,
    );
    expect(
        state.getDisplayedCameras(),
        cameras
            .where((camera) => camera.isFavourite)
            .where((camera) => camera.name.trim().containsIgnoreCase('l'))
            .toList()
          ..sort((a, b) {
            int result = a.neighbourhood.compareTo(b.neighbourhood);
            return result == 0
                ? a.sortableName.compareTo(b.sortableName)
                : result;
          }));
  });
}
