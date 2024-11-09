import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/camera.dart';
import '../entities/city.dart';

class DownloadService {
  static Future<Uint8List?> getVideoFrame(String url) async {
    return await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      quality: 100,
    );
  }

  static Future<List<String>> getHtmlImages(String url,
      {bool includeTime = false}) async {
    String data = await http.read(Uri.parse(url));
    RegExp regex = RegExp('cameraimages/.*?"');
    return regex.allMatches(data).map((RegExpMatch match) {
      String str = match.group(0)!.replaceAll('"', '');
      String time =
          includeTime ? '?timems=${DateTime.now().millisecondsSinceEpoch}' : '';
      return 'https://trafficcams.vancouver.ca/$str$time';
    }).toList();
  }

  static Future<List<Camera>> getCameras(City city) async {
    String apiKey = await rootBundle.loadString('assets/api_key.txt');
    SupabaseClient supabaseClient = SupabaseClient(
      'https://nacudfxzbqaesoyjfluh.supabase.co',
      apiKey,
    );
    List<Map<String, dynamic>> data =
        await supabaseClient.from('cameras').select().eq('city', city.name);
    List<Map<String, dynamic>> page2 = await supabaseClient
        .from('cameras')
        .select()
        .eq('city', city.name)
        .range(1000, 2000);
    data.addAll(page2);
    return data.map((item) => Camera.fromJson(item)).toList();
  }
}
