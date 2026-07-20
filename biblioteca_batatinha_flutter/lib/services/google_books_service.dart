import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/constants/supabase_config.dart';

class GoogleBookModel {
  final String title;
  final List<String> authors;
  final String? genre;
  final String? coverUrl;
  final String? infoLink;
  final String? language;

  GoogleBookModel({
    required this.title,
    required this.authors,
    this.genre,
    this.coverUrl,
    this.infoLink,
    this.language,
  });

  factory GoogleBookModel.fromJson(Map<String, dynamic> volumeInfo) {
    final title = volumeInfo['title'] as String? ?? 'Sem Título';
    final authors = volumeInfo['autores'] != null || volumeInfo['authors'] != null
        ? List<String>.from((volumeInfo['authors'] ?? volumeInfo['autores']) as List)
        : <String>[];
    final categories = volumeInfo['categories'] as List?;
    final genre = categories != null && categories.isNotEmpty ? categories.first.toString() : null;
    final imageLinks = volumeInfo['imageLinks'] as Map<String, dynamic>?;
    final coverUrl = imageLinks != null
        ? (imageLinks['thumbnail'] as String? ?? imageLinks['smallThumbnail'] as String?)?.replaceAll('http://', 'https://')
        : null;
    final infoLink = volumeInfo['infoLink'] as String?;
    final langRaw = volumeInfo['language'] as String?;
    
    String? language;
    if (langRaw != null) {
      if (langRaw.startsWith('pt')) {
        language = 'Português';
      } else if (langRaw.startsWith('en')) {
        language = 'Inglês';
      } else if (langRaw.startsWith('es')) {
        language = 'Espanhol';
      }
    }

    return GoogleBookModel(
      title: title,
      authors: authors,
      genre: genre,
      coverUrl: coverUrl,
      infoLink: infoLink,
      language: language,
    );
  }
}

class GoogleBooksService {
  static Future<List<GoogleBookModel>> search(String query) async {
    if (query.trim().isEmpty) return [];

    const apiKey = SupabaseConfig.googleBooksApiKey;
    final uri = Uri.parse('https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeQueryComponent(query)}&key=$apiKey&maxResults=10');
    
    int retries = 3;
    Duration delay = const Duration(seconds: 1);

    while (retries > 0) {
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri);
        request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
        final response = await request.close();

        debugPrint('Google Books status code: ${response.statusCode}');

        if (response.statusCode == 200) {
          final content = await response.transform(utf8.decoder).join();
          final data = jsonDecode(content) as Map<String, dynamic>;
          final items = data['items'] as List?;
          if (items == null) return [];

          return items
              .map((item) => item['volumeInfo'] as Map<String, dynamic>?)
              .where((info) => info != null)
              .map((info) => GoogleBookModel.fromJson(info!))
              .toList();
        } else if (response.statusCode == 429) {
          debugPrint('Rate limited (429). Retrying in ${delay.inSeconds}s... ($retries retries left)');
          await Future.delayed(delay);
          delay *= 2;
          retries--;
        } else {
          debugPrint('Google Books HTTP request failed with code: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        debugPrint('Google Books Search Network Error: $e. Retrying in ${delay.inSeconds}s...');
        await Future.delayed(delay);
        delay *= 2;
        retries--;
      } finally {
        client.close();
      }
    }
    return [];
  }
}
