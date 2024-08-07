import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyin/provider/story_provider.dart';
import 'package:storyin/utils/result_state.dart';
import 'package:storyin/utils/time_formatter.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;
  final Function(double, double) isShowMap;
  const StoryDetailScreen(
      {super.key, required this.storyId, required this.isShowMap});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Detail Story"),
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
          IconButton(
            onPressed: () {
              final story = context.read<StoryProvider>().storyDetail;
              if (story != null && story.lat != null && story.lon != null) {
                widget.isShowMap(story.lat!, story.lon!);
              }
            },
            icon: const Icon(
              Icons.location_on,
              color: Color(0xFF10439F),
            ),
          )
        ],
      ),
      body: Consumer<StoryProvider>(
        builder: (context, provider, child) {
          if (provider.state == ResultState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.state == ResultState.hasData) {
            final story = provider.storyDetail;
            return story == null
                ? const Center(child: Text('Story not found'))
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(story.photoUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 10,
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        timeAgo(story.createdAt),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 3.0,
                                              color: Colors.black,
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        story.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26.0,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 3.0,
                                              color: Colors.black,
                                              offset: Offset(1.0, 1.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              story.description,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (story.lon != null && story.lat != null) ...[]
                        ],
                      ),
                    ),
                  );
          } else if (provider.state == ResultState.error) {
            return Center(child: Text(provider.message));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
