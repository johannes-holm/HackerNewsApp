import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../data/models/item.dart';
import '../top_stories/top_stories_controller.dart';

class TopStoriesPage extends ConsumerWidget {
  const TopStoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(topStoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Top Stories')),
      body: storiesAsync.when(
        data:
            (stories) => ListView.builder(
              itemCount: stories.length,
              itemBuilder: (_, i) {
                final item = stories[i];
                final date = DateTime.fromMillisecondsSinceEpoch(
                  item.timestamp * 1000,
                );

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          // navigate to /user/:id
                          context.push('/user/${item.author}');
                        },
                        child: Text(
                          item.author,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 2) a little separator dot
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•', style: TextStyle(fontSize: 12)),
                      ),

                      // 3) the timestamp
                      Text(
                        date.toLocal().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // open the story URL on tap
                  onTap:
                      item.url != null
                          ? () => launchUrlString(item.url!)
                          : null,
                );
              },
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
