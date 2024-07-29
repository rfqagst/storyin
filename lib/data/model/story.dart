import 'dart:convert';

// Model untuk ListStory
class Story {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final String createdAt;
  final double? lat;
  final double? lon;

  Story({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
    this.lat,
    this.lon,
  });

  // Factory constructor untuk membuat Story dari JSON
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'],
      lat: json['lat'] != null ? json['lat'].toDouble() : null,
      lon: json['lon'] != null ? json['lon'].toDouble() : null,
    );
  }

  // Method untuk mengubah Story menjadi Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'lat': lat,
      'lon': lon,
    };
  }
}

// Model untuk Response
class StoriesResponse {
  final bool error;
  final String message;
  final List<Story> listStory;

  StoriesResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  // Factory constructor untuk membuat StoriesResponse dari JSON
  factory StoriesResponse.fromJson(Map<String, dynamic> json) {
    var listStoryFromJson = json['listStory'] as List;
    List<Story> listStoryList =
        listStoryFromJson.map((i) => Story.fromJson(i)).toList();

    return StoriesResponse(
      error: json['error'],
      message: json['message'],
      listStory: listStoryList,
    );
  }

  // Method untuk mengubah StoriesResponse menjadi Map
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'listStory': listStory.map((story) => story.toJson()).toList(),
    };
  }
}

class StoryDetailResponse {
  final bool error;
  final String message;
  final Story story;

  StoryDetailResponse({
    required this.error,
    required this.message,
    required this.story,
  });

  // Factory constructor untuk membuat StoryDetailResponse dari JSON
  factory StoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return StoryDetailResponse(
      error: json['error'],
      message: json['message'],
      story: Story.fromJson(json['story']),
    );
  }

  // Method untuk mengubah StoryDetailResponse menjadi Map
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'message': message,
      'story': story.toJson(),
    };
  }
}

// Fungsi untuk mengonversi JSON string ke StoryDetailResponse
StoryDetailResponse parseStoryDetailResponse(String jsonString) {
  final jsonData = json.decode(jsonString);
  return StoryDetailResponse.fromJson(jsonData);
}

// Fungsi untuk mengonversi StoryDetailResponse ke JSON string
String storyDetailResponseToJson(StoryDetailResponse data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
