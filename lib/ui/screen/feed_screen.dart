import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyin/data/model/story.dart';
import 'package:storyin/provider/auth_provider.dart';
import 'package:storyin/provider/story_provider.dart';
import 'package:storyin/ui/widget/feed_card.dart';
import 'package:storyin/utils/auth_state.dart';
import 'package:storyin/utils/result_state.dart';

class FeedScreen extends StatefulWidget {
  final Function(String) onTapped;
  final Function() onLogout;
  final Function() onAddStory;

  const FeedScreen({
    super.key,
    required this.onLogout,
    required this.onTapped,
    required this.onAddStory,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StoryProvider>(context, listen: false).fetchStories();
    });
  }

  Future<void> _refreshStories() async {
    await Provider.of<StoryProvider>(context, listen: false).fetchStories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color.fromARGB(19, 99, 98, 98),
                offset: Offset(0, 4),
                blurRadius: 10)
          ]),
        ),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                onPressed: () async {
                  final result = await authProvider.logout();
                  if (result) widget.onLogout();
                },
                icon: authProvider.state == AuthState.loading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF10439F),
                      )
                    : const Icon(Icons.logout),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<StoryProvider>(builder: (context, provider, child) {
          if (provider.state == ResultState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.state == ResultState.error) {
            return Center(child: Text(provider.message));
          } else if (provider.state == ResultState.hasData) {
            return RefreshIndicator(
              onRefresh: _refreshStories,
              child: ListView.builder(
                itemCount: provider.stories.length,
                itemBuilder: (context, index) {
                  final story = provider.stories[index];
                  return FeedCard(
                    story: story,
                    onTapped: widget.onTapped,
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text("No stories found"));
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF10439F),
        onPressed: () {
          widget.onAddStory();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
