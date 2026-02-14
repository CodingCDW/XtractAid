import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

/// A single item to be processed by the LLM.
@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String text,
    String? source, // File path or sheet name
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}
