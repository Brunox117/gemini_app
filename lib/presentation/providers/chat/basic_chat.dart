import 'package:gemini_app/config/gemini/gemini_impl.dart';
import 'package:gemini_app/presentation/providers/chat/is_gemini_writing.dart';
import 'package:gemini_app/presentation/providers/users/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:uuid/uuid.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {
  final gemini = GeminiImpl();
  late User geminiUser;
  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    return [];
  }

  void addMessage({
    required PartialText partialText,
    required User user,
    List<XFile> images = const [],
  }) {
    if (images.isNotEmpty) {
      _addTextMessageWithImages(
        partialText: partialText,
        user: user,
        images: images,
      );
      return;
    }
    _addTextMessage(partialText: partialText, user: user);
  }

  void _addTextMessage({required PartialText partialText, required User user}) {
    _createTextMessage(partialText.text, user);
    _geminiTextResponseStream(partialText.text);
  }

  void _addTextMessageWithImages({
    required PartialText partialText,
    required User user,
    required List<XFile> images,
  }) async {
    for (XFile image in images) {
      _createImageMessage(image, user);
    }
    await Future.delayed(Duration(milliseconds: 10), () {
      _createTextMessage(partialText.text, user);
    });
    _geminiTextResponseStream(partialText.text, images: images);
  }

  void _geminiTextResponse(String prompt) async {
    _setGeminiWritingStatus(true);

    final textResponse = await gemini.getResponse(prompt);
    _createTextMessage(textResponse, geminiUser);
    _setGeminiWritingStatus(false);
  }

  void _geminiTextResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async {
    _createTextMessage('Gemini está pensando', geminiUser);
    gemini.getResponseStream(prompt, images: images).listen((responseChunk) {
      if (responseChunk.isEmpty) return;
      final updatedMessages = [...state];
      final updatedMessage = (updatedMessages.first as TextMessage).copyWith(
        text: responseChunk,
      );
      updatedMessages[0] = updatedMessage;
      state = updatedMessages;
    });
  }

  //Helper methods
  void _createTextMessage(String textResponse, User author) {
    final message = TextMessage(
      author: author,
      id: uuid.v4(),
      text: textResponse,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [message, ...state];
  }

  Future<void> _createImageMessage(XFile image, User author) async {
    final message = ImageMessage(
      author: author,
      id: uuid.v4(),
      uri: image.path,
      name: image.name,
      size: await image.length(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    state = [message, ...state];
  }

  void _setGeminiWritingStatus(bool isWriting) {
    final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);
    isWriting
        ? isGeminiWriting.setIsWriting()
        : isGeminiWriting.setIsNotWriting();
  }
}
