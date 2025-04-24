import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/item.dart';
import '../../data/providers/api_providers.dart';

final topStoriesProvider = FutureProvider<List<Item>>((ref) async {
  final api = ref.watch(hnApiProvider);
  final ids = await api.getTopStoryIds();
  // Fetch only the first 20 for performance
  final futures = ids.take(20).map((id) => api.getItem(id));
  return Future.wait(futures);
});
