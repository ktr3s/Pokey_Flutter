import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokey_music/models/music_model.dart';

class MusicRepository {
  final String baseUrl = "http://10.0.2.2:8000"; // reemplaza por el real
  final String authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1IiwiZXhwIjoxNzUzMzMzMTM3fQ.5FKeT_U8FU3rK2SQOSuQcnyaxjTYNyMypI7SpT5-6oY";
  Future<List<Music>> fetchMusicList() async {
    final response = await http.get(Uri.parse("$baseUrl/music/all"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken"
        }
        );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      print("AQUI $jsonList");
      return jsonList.map((json) => Music.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar la música");
    }
  }
}
