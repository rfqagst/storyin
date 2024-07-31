import 'package:flutter/material.dart';
import 'package:storyin/data/db/auth_repository.dart';
import 'package:storyin/provider/story_provider.dart';
import 'package:storyin/ui/screen/add_story_screen.dart';
import 'package:storyin/ui/screen/auth/login_screen.dart';
import 'package:storyin/ui/screen/auth/register_screen.dart';
import 'package:storyin/ui/screen/feed_screen.dart';
import 'package:storyin/ui/screen/map/map_screen.dart';
import 'package:storyin/ui/screen/map/pick_map_screen.dart';
import 'package:storyin/ui/screen/story_detail_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthRepository authRepository;
  final StoryProvider storyProvider;

  MyRouterDelegate(this.authRepository, this.storyProvider)
      : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  _init() async {
    isLoading = true;
    isLoggedIn = await authRepository.isLoggedIn();
    if (isLoggedIn == true) {
      await storyProvider.fetchStories();
    }
    isLoading = false;

    notifyListeners();
  }

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool isAddingStory = false;
  bool isShowMap = false;
  bool isPickLocation = false;
  bool isLoading = false;
  double? lat;
  double? lon;

  List<Page> get _loadingStack => [
        const MaterialPage(
          child: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          child: LoginScreen(
            onLogin: () async {
              isLoggedIn = true;
              await storyProvider.fetchStories();
              notifyListeners();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
              onRegister: () {
                isLoggedIn = false;
                notifyListeners();
              },
            ),
          ),
      ];

  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("FeedScreen"),
          child: FeedScreen(
            onLogout: () {
              isLoggedIn = false;
              notifyListeners();
            },
            onTapped: (storyId) {
              selectedStory = storyId;
              storyProvider.fetchStoryDetail(storyId);
              notifyListeners();
            },
            onAddStory: () {
              isAddingStory = true;
              notifyListeners();
            },
          ),
        ),
        if (selectedStory != null)
          MaterialPage(
            key: ValueKey(selectedStory),
            child: StoryDetailScreen(
              storyId: selectedStory!,
              isShowMap: (lat, lon) {
                this.lat = lat;
                this.lon = lon;
                isShowMap = true;
                notifyListeners();
              },
            ),
          ),
        if (isAddingStory)
          MaterialPage(
            key: const ValueKey("AddStoryScreen"),
            child: AddStoryScreen(
              onStoryUploaded: () async {
                await storyProvider.fetchStories();
                isAddingStory = false;
                notifyListeners();
              },
              isPickLocation: () {
                isPickLocation = true;
                notifyListeners();
              },
            ),
          ),
        if (isShowMap)
          MaterialPage(
            key: const ValueKey("MapScreen"),
            child: MapScreen(
              lat: lat!,
              lon: lon!,
            ),
          ),
        if (isPickLocation)
          MaterialPage(
            key: const ValueKey("PickMapScreen"),
            child: PickMapScreen(
              onPickedLocation: () {
                
              },
            ),
          ),
      ];

  String? selectedStory;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      historyStack = _loadingStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        isRegister = false;
        selectedStory = null;
        isAddingStory = false;
        isShowMap = false;
        isPickLocation = false;


        notifyListeners();

        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  @override
  Future<void> setNewRoutePath(configuration) {
    throw UnimplementedError();
  }
}
