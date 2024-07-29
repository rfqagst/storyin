import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storyin/data/api/api_service.dart';
import 'package:storyin/data/db/auth_repository.dart';
import 'package:storyin/provider/auth_provider.dart';
import 'package:storyin/provider/story_provider.dart';
import 'package:storyin/routes/router_delegate.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late AuthProvider authProvider;
  late StoryProvider storyProvider;
  late MyRouterDelegate myRouterDelegate;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();
    authProvider = AuthProvider(
      apiService: ApiService(),
      authRepository: authRepository,
    );
    storyProvider = StoryProvider(
      apiService: ApiService(),
      authRepository: authRepository,
    );
    myRouterDelegate = MyRouterDelegate(authRepository, storyProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider<StoryProvider>(
          create: (context) => storyProvider,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
