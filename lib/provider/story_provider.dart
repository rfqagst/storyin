import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:storyin/data/api/api_service.dart';
import 'package:storyin/data/db/auth_repository.dart';
import 'package:storyin/data/model/story.dart';
import 'package:storyin/data/model/user.dart';
import 'package:storyin/utils/post_state.dart';
import 'package:storyin/utils/result_state.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService apiService;
  final AuthRepository authRepository;

  StoryProvider({required this.apiService, required this.authRepository}) {
    _message = '';
    _stories = [];
    _storyDetail = null;
    _state = ResultState.idle;
    _postState = PostState.idle;
  }

  late ResultState _state;
  ResultState get state => _state;

  late PostState _postState;
  PostState get postState => _postState;

  late String _message;
  String get message => _message;

  late List<Story> _stories;
  List<Story> get stories => _stories;

  Story? _storyDetail;
  Story? get storyDetail => _storyDetail;

  XFile? imageFile;
  String? imagePath;

  int? pageItems = 1;
  int sizeItems = 10;

  void resetPage() {
    pageItems = 1;
  }

  Future<void> fetchStories() async {
    try {
      final User? user = await authRepository.getUser();
      if (user != null && user.token != null) {
        if (pageItems == 1) {
          _state = ResultState.loading;
          notifyListeners();
        }
        final storiesResponse = await apiService.getStories(
            token: user.token!, page: pageItems!, size: sizeItems);
        if (pageItems == 1) {
          _stories = storiesResponse.listStory;
        } else {
          _stories.addAll(storiesResponse.listStory);
        }
        _state = ResultState.hasData;

        if (storiesResponse.listStory.length < sizeItems) {
          pageItems = null;
        } else {
          pageItems = pageItems! + 1;
        }

        notifyListeners();
      } else {
        _message = "User is not logged in";
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

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  Future<void> postStory({
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    _postState = PostState.loading;
    notifyListeners();

    try {
      final User? user = await authRepository.getUser();
      if (user != null && user.token != null) {
        final response = await apiService.postStory(
            token: user.token!,
            description: description,
            photo: photo,
            lat: lat,
            lon: lon);

        if (response['error'] == false) {
          _postState = PostState.success;
          _message = response['message'];
        } else {
          _postState = PostState.error;
          _message = response['message'];
          throw Exception('Error in posting story');
        }
      } else {
        _postState = PostState.error;
        _message = "User is not logged in";
        throw Exception('User is not logged in');
      }
    } catch (e) {
      _postState = PostState.error;
      _message = e.toString();
    }
    notifyListeners();
    _resetPostState();
  }

  void _resetPostState() {
    _postState = PostState.idle;
    _message = '';
    pageItems = 1;
    _stories = [];
    notifyListeners();
  }
}
