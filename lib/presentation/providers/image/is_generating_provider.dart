
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'is_generating_provider.g.dart';

@riverpod
class IsGenerating extends _$IsGenerating {
  @override
   bool build() => false;
  
  void setIsGenerating(){
    state = true;
  }
  void setIsNotGenerating(){
    state = false;
  }
}