import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class GeminiImpl {
  final Dio _http = Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});

      final response = await _http.post('/basic-prompt', data: body);
      return response.data;
    } catch (e) {
      print(e);
      throw Exception("Can't get gemini response");
    }
  }

  Stream<String> getResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async* {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));
    if (images.isNotEmpty) {
      for (final file in images) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }

    // final body = jsonEncode({'prompt': prompt});
    final response = await _http.post(
      '/basic-prompt-stream',
      data: formData,
      options: Options(responseType: ResponseType.stream),
    );
    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';
    await for (final chunk in stream) {
      final chunkString = utf8.decode(chunk, allowMalformed: true);
      buffer += chunkString;
      yield buffer;
    }
  }

  Stream<String> getChatStream(
    String prompt,
    String chatId, {
    List<XFile> images = const [],
  }) async* {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));
    formData.fields.add(MapEntry('chatId', chatId));
    if (images.isNotEmpty) {
      for (final file in images) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }

    // final body = jsonEncode({'prompt': prompt});
    final response = await _http.post(
      '/chat-stream',
      data: formData,
      options: Options(responseType: ResponseType.stream),
    );
    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';
    await for (final chunk in stream) {
      final chunkString = utf8.decode(chunk, allowMalformed: true);
      buffer += chunkString;
      yield buffer;
    }
  }
}
