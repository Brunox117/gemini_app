import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated_history_provider.g.dart';

@riverpod
class GeneratedHistory extends _$GeneratedHistory {
  @override
  List<String> build() => [];
  void addImage(String imageUrl) {
    state = [imageUrl, ...state];
  }
}
