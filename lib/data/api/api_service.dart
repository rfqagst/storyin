import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:storyin/data/model/story.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const _baseUrl = "https://story-api.dicoding.dev/v1";

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['message']);
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      throw Exception(errorResponse['message']);
    }
  }

  Future<StoriesResponse> getStories({
    required String token,
  }) async {
    final url = Uri.parse('$_baseUrl/stories');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      return StoriesResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Failed load data from server");
    }
  }

  Future<StoryDetailResponse> getDetail(
      {required String id, required String token}) async {
    final url = Uri.parse('$_baseUrl/stories/$id');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      return StoryDetailResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception("Failed load data from server");
    }
  }

  Future<Map<String, dynamic>> postStory({
    required String token,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    final url = Uri.parse('$_baseUrl/stories');

    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['description'] = description;

    if (lat != null) {
      request.fields['lat'] = lat.toString();
    }
    if (lon != null) {
      request.fields['lon'] = lon.toString();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      throw Exception("Failed to post story");
    }
  }
}
