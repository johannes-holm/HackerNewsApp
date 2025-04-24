import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../top_stories/top_stories_controller.dart';

class TopStoriesPage extends ConsumerWidget {
  const TopStoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(topStoriesProvider);
    final _minuteFormatter = DateFormat('yyyy-MM-dd HH:mm');
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        elevation: 2,
        title: Text(
          'Top Stories',
          style: GoogleFonts.openSans(
            textStyle: const TextStyle(
              color: Colors.cyanAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
      body: storiesAsync.when(
        data:
            (stories) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView.builder(
                itemCount: stories.length,
                itemBuilder: (_, i) {
                  final item = stories[i];
                  final date = DateTime.fromMillisecondsSinceEpoch(
                    item.timestamp * 1000,
                  );
                  // Format to minute precision:
                  final formatted = _minuteFormatter.format(date.toLocal());

                  return GestureDetector(
                    onTap:
                        item.url != null
                            ? () => launchUrlString(item.url!)
                            : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyanAccent,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.5),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            item.title!,
                            style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Author & timestamp row
                          Row(
                            children: [
                              // Author as TextButton
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.cyanAccent,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {
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
                              const SizedBox(width: 8),
                              // Separator
                              const Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Timestamp
                              Text(
                                formatted,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
        error:
            (e, _) => Center(
              child: Text(
                'Error: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
      ),
    );
  }
}
