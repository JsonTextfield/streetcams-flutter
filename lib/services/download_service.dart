import 'package:change_case/change_case.dart';
import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart' as intl;

import '../entities/camera.dart';

class DownloadService {
  static Future<Uint8List?> getVideoFrame(String url) async {
    return await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
  }

  static Future<List<Camera>> getVancouverCameras(List<Camera> cameras) async {
    List<Camera> result = [];
    for (var camera in cameras) {
      var urls = await getVancouverImages(camera.url, includeTime: true);
      result.addAll(urls.map((url) => camera.copyWith(url: url)));
    }
    return result;
  }

  static Future<List<String>> getVancouverImages(
    String url, {
    bool includeTime = false,
  }) async {
    final data = await http.read(Uri.parse(url));
    final matches = RegExp('cameraimages/.*?"').allMatches(data);

    return matches.map((match) {
      final path = match.group(0)!.replaceAll('"', '');
      final timestamp =
          includeTime ? '?timems=${DateTime.now().millisecondsSinceEpoch}' : '';
      return 'https://trafficcams.vancouver.ca/$path$timestamp';
    }).toList();
  }

  static Future<bool> saveImage(Camera camera) async {
    try {
      Uri url = Uri.parse(camera.url);
      Uint8List bytes = await http.readBytes(url);
      String fileName =
          '${camera.name.toPascalCase()}${intl.DateFormat('_yyyy_MM_dd_kk_mm_ss').format(DateTime.now())}.jpg';
      await ImageGallerySaverPlus.saveImage(bytes, name: fileName);
      return true;
    } on Exception catch (_) {
      return false;
    }
  }
}
