import 'package:flutter/material.dart';
import 'package:storyin/data/model/story.dart';
import 'package:storyin/utils/time_formatter.dart';

class FeedCard extends StatelessWidget {
  final Story story;
  final Function(String) onTapped;

  const FeedCard({super.key, required this.story, required this.onTapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTapped(story.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(story.photoUrl),
                  radius: 25.0,
                ),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff171515),
                      ),
                    ),
                    Text(
                      timeAgo(story.createdAt),
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF7E7777)),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "${story.name}  ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Color(0xff171515),
                    ),
                  ),
                  TextSpan(
                    text: story.description,
                    style: const TextStyle(
                      color: Color(0xff171515),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
