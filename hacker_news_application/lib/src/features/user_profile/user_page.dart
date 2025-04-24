import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../data/models/item.dart';
import '../../data/models/user.dart';
import '../../data/providers/api_providers.dart';

// 1a. Fetch a single user by id
final userProvider = FutureProvider.family<User, String>((ref, userId) {
  final api = ref.watch(hnApiProvider);
  return api.getUser(userId);
});

// 1b. Fetch a list of Items given their IDs
final userItemsProvider = FutureProvider.family<List<Item>, List<int>>((
  ref,
  submittedIds,
) {
  final api = ref.watch(hnApiProvider);
  // limit to, say, 20 posts for performance
  return Future.wait(submittedIds.take(20).map(api.getItem));
});

class UserPage extends ConsumerWidget {
  final String userId;
  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return userAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (e, st) =>
              Scaffold(body: Center(child: Text('Error loading user: $e'))),
      data: (user) {
        final created = DateTime.fromMillisecondsSinceEpoch(
          user.created * 1000,
        );
        final itemsAsync = ref.watch(userItemsProvider(user.submitted));

        return Scaffold(
          appBar: AppBar(title: Text(user.id)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Joined: ${created.toLocal()}',
                  style: TextStyle(fontSize: 16),
                ),
                if (user.about != null) ...[
                  const SizedBox(height: 12),
                  Text('About:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    user.about!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Posts:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: itemsAsync.when(
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data:
                        (items) => ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final it = items[i];
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              it.timestamp * 1000,
                            );
                            return ListTile(
                              title: Text(it.title),
                              subtitle: Text(date.toLocal().toString()),
                              onTap: () {
                                if (it.url != null) {
                                  launchUrlString(it.url!);
                                }
                              },
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
