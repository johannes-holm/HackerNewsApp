import 'package:go_router/go_router.dart';
import '../features/top_stories/top_stroies_page.dart';
import '../features/user_profile/user_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, state) => TopStoriesPage()),
    GoRoute(
      path: '/user/:id',
      builder: (_, state) {
        final id = state.pathParameters['id']!;
        return UserPage(userId: id);
      },
    ),
  ],
);
