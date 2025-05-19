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
      throw Exception("Can't get gemini response");
    }
  }

  Stream<String> getResponseStream(
    String prompt, {
    List<XFile> images = const [],
  }) async* {
    yield* _getStreamResponse(
      prompt: prompt,
      endpoint: '/basic-prompt-stream',
      files: images,
    );
  }

  Stream<String> getChatStream(
    String prompt,
    String chatId, {
    List<XFile> images = const [],
  }) async* {
    yield* _getStreamResponse(
      prompt: prompt,
      endpoint: '/chat-stream',
      files: images,
      formFields: {'chatId': chatId},
    );
  }

  // Emitir el stream de informacion
  Stream<String> _getStreamResponse({
    required String prompt,
    required String endpoint,
    List<XFile> files = const [],
    Map<String, dynamic> formFields = const {},
  }) async* {
    //Agregamos las entradas
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));
    for (final entry in formFields.entries) {
      formData.fields.add(MapEntry(entry.key, entry.value));
    }
    //Agregamos los archivos
    if (files.isNotEmpty) {
      for (final file in files) {
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
      endpoint,
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

  Future<String?> generateImage(
    String prompt, {
    List<XFile> files = const [],
  }) async {
    final formData = FormData();
    formData.fields.add(MapEntry('prompt', prompt));
    if (files.isNotEmpty) {
      for (final file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
    }
    try {
      final response = await _http.post('/image-generation', data: formData);
      return response.data['imageUrl'];
    } catch (e) {
      print(e);
      return null;
    }
  }
}
