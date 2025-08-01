import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokey_music/models/auth_model.dart';

class AuthRepository {
  final String baseUrl =
      'http://10.0.2.2:8000/users/login'; // Cambia según dispositivo

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Login fallido');
    }
  }
}
