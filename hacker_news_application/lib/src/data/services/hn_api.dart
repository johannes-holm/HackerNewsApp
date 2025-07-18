import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/item.dart';
import '../models/user.dart';

part 'hn_api.g.dart';

@RestApi(baseUrl: 'https://hacker-news.firebaseio.com/v0/')
abstract class HnApi {
  factory HnApi(Dio dio, {String baseUrl}) = _HnApi;

  @GET('topstories.json')
  Future<List<int>> getTopStoryIds();

  @GET('item/{id}.json')
  Future<Item> getItem(@Path('id') int id);

  @GET('user/{id}.json')
  Future<User> getUser(@Path('id') String id);
}
