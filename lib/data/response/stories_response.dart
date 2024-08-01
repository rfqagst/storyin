import 'package:json_annotation/json_annotation.dart';
import 'package:storyin/data/model/story.dart';

part 'stories_response.g.dart';

@JsonSerializable()
class StoriesResponse {
  final bool error;
  final String message;
  final List<Story> listStory;

  StoriesResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoriesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoriesResponseToJson(this);
}
