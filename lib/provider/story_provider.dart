import 'package:flutter/material.dart';
import 'package:storyin/data/api/api_service.dart';
import 'package:storyin/data/db/auth_repository.dart';
import 'package:storyin/data/model/story.dart';
import 'package:storyin/data/model/user.dart';
import 'package:storyin/utils/result_state.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  StoryProvider({required this.apiService, required this.authRepository}) {
    _message = '';
    _stories = [];
    _storyDetail = null;
    _state = ResultState.idle;
  }

  late ResultState _state;
  ResultState get state => _state;

  late String _message;
  String get message => _message;

  late List<Story> _stories;
  List<Story> get stories => _stories;

  Story? _storyDetail;
  Story? get storyDetail => _storyDetail;

  Future<void> fetchStories() async {
    _state = ResultState.loading;
    notifyListeners();
    try {
      final User? user = await authRepository.getUser();
      if (user != null && user.token != null) {
        final storiesResponse = await apiService.getStories(token: user.token!);
        _stories = storiesResponse.listStory;
        _state = ResultState.hasData;
      } else {
        throw Exception('User is not logged in');
      }
    } catch (e) {
      _state = ResultState.error;
      _message = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchStoryDetail(String id) async {
    _state = ResultState.loading;
    notifyListeners();
    try {
      final User? user = await authRepository.getUser();
      if (user != null && user.token != null) {
        final storyDetailResponse =
            await apiService.getDetail(id: id, token: user.token!);
        _storyDetail = storyDetailResponse.story;
        _state = ResultState.hasData;
      } else {
        throw Exception('User is not logged in');
      }
    } catch (e) {
      _state = ResultState.error;
      _message = e.toString();
    }
    notifyListeners();
  }
}
