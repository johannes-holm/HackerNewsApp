import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/item.dart';
import '../../data/models/user.dart';
import '../../data/providers/api_providers.dart';

final _minuteFormatter = DateFormat('yyyy-MM-dd HH:mm');

final userProvider = FutureProvider.family<User, String>((ref, userId) {
  final api = ref.watch(hnApiProvider);
  return api.getUser(userId);
});

final userItemsProvider = FutureProvider.family<List<Item>, List<int>>((
  ref,
  submittedIds,
) async {
  final api = ref.watch(hnApiProvider);
  final stories = <Item>[];

  for (final id in submittedIds) {
    try {
      final it = await api.getItem(id);
      if (it.type == 'story' && it.title != null) {
        stories.add(it);
      }
    } catch (_) {}
    if (stories.length >= 20) break;
  }

  return stories;
});

class UserPage extends ConsumerWidget {
  final String userId;
  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider(userId));

    return userAsync.when(
      loading:
          () => const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          ),
      error:
          (e, _) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Error loading user: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
      data: (user) {
        final joined = DateTime.fromMillisecondsSinceEpoch(user.created * 1000);
        final joinedStr = _minuteFormatter.format(joined.toLocal());
        final itemsAsync = ref.watch(userItemsProvider(user.submitted));

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                context.go('/');
              },
              icon: Icon(Icons.arrow_back, color: Colors.white),
            ),
            backgroundColor: Colors.grey[900],
            title: Text(
              user.id,
              style: GoogleFonts.openSans(
                textStyle: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Joined: $joinedStr',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      if (user.about != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'About:',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.about!,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'Posts',
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // User's posts
                Expanded(
                  child: itemsAsync.when(
                    loading:
                        () => const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        ),
                    error:
                        (e, _) => Center(
                          child: Text(
                            'Error: $e',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    data:
                        (items) => ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, idx) {
                            final it = items[idx];
                            final created = DateTime.fromMillisecondsSinceEpoch(
                              it.timestamp * 1000,
                            );
                            final ts = _minuteFormatter.format(
                              created.toLocal(),
                            );

                            return InkWell(
                              onTap: () {
                                final url =
                                    it.url ??
                                    'https://news.ycombinator.com/item?id=${it.id}';
                                launchUrlString(url);
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.cyanAccent,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.title!,
                                      style: GoogleFonts.openSans(
                                        textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ts,
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
