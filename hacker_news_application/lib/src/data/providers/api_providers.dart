import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../services/hn_api.dart';

final dioProvider = Provider((_) => Dio());
final hnApiProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return HnApi(dio);
});
