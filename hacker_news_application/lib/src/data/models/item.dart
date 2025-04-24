import 'package:freezed_annotation/freezed_annotation.dart';
part 'item.freezed.dart';
part 'item.g.dart';

@freezed
class Item with _$Item {
  const factory Item({
    required int id,
    required String title,
    @JsonKey(name: 'by') required String author,
    @JsonKey(name: 'time') required int timestamp,
    String? url,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
