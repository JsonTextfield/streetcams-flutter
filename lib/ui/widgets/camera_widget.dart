import 'dart:typed_data';
import 'dart:ui';

import 'package:change_case/change_case.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart' as intl;
import 'package:streetcams_flutter/l10n/translation.dart';

import '../../entities/camera.dart';

class CameraWidget extends StatelessWidget {
  // Widget for an individual camera feed
  final Camera camera;
  final String otherUrl;

  const CameraWidget(this.camera, {super.key, this.otherUrl = ''});

  @override
  Widget build(BuildContext context) {
    debugPrint('building camera widget');
    return GestureDetector(
      onLongPress: () => _saveImage(camera).then((bool result) {
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.translation.imageSaved(camera.name)),
          ));
        }
      }),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height -
              MediaQueryData.fromView(View.of(context)).padding.top,
        ),
        child: Stack(
          textDirection: TextDirection.ltr,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
                tileMode: TileMode.decal,
              ),
              child: Image.network(
                otherUrl.isNotEmpty ? otherUrl : camera.url,
                fit: BoxFit.fitWidth,
                gaplessPlayback: true,
                width: MediaQuery.sizeOf(context).width,
                errorBuilder: (context, exception, stacktrace) {
                  return const SizedBox();
                },
              ),
            ),
            Image.network(
              otherUrl.isNotEmpty ? otherUrl : camera.url,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: Center(
                    child: Icon(
                      Icons.videocam_off_rounded,
                      size: 50,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                );
              },
              semanticLabel: camera.name,
              fit: BoxFit.contain,
              width: MediaQuery.sizeOf(context).width,
              gaplessPlayback: true,
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Text(
                    camera.name,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _saveImage(Camera camera) async {
    try {
      Uri url = Uri.parse(otherUrl.isNotEmpty ? otherUrl : camera.url);
      Uint8List bytes = await http.readBytes(url);
      String fileName =
          '${camera.name.toPascalCase}${intl.DateFormat('_yyyy_MM_dd_kk_mm_ss').format(DateTime.now())}.jpg';
      await ImageGallerySaverPlus.saveImage(bytes, name: fileName);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
