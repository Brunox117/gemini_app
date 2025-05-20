import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_art_provider.g.dart';

@riverpod
class SelectedArt extends _$SelectedArt {
  @override
  build() => '';

  void setSelectedArt(String art) {
    if (state == art) {
      state = '';
      return;
    }
    state = art;
  }
}
