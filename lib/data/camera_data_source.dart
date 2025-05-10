import 'package:supabase_flutter/supabase_flutter.dart';

import '../entities/camera.dart';
import '../entities/city.dart';

abstract class ICameraDataSource {

  Future<List<Camera>> getAllCameras(City city);

}

class SupabaseCameraDataSource extends ICameraDataSource {
  final SupabaseClient _supabaseClient;

  SupabaseCameraDataSource(this._supabaseClient);

  @override
  Future<List<Camera>> getAllCameras(City city) async {
    List<Map<String, dynamic>> data =
    await _supabaseClient.from('cameras').select().eq('city', city.name);
    List<Map<String, dynamic>> page2 = await _supabaseClient
        .from('cameras')
        .select()
        .eq('city', city.name)
        .range(1000, 2000);
    return (data + page2).map((item) => Camera.fromJson(item)).toList();
  }
}