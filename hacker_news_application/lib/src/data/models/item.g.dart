// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      author: json['by'] as String,
      timestamp: (json['time'] as num).toInt(),
      url: json['url'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'by': instance.author,
      'time': instance.timestamp,
      'url': instance.url,
      'type': instance.type,
    };
