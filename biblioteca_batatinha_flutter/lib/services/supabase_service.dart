import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livro.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  final SupabaseClient _client = Supabase.instance.client;

  // Retrieve list of books
  Future<List<Livro>> listar() async {
    final response = await _client
        .from('livros')
        .select()
        .order('criado_em', ascending: false);
    
    return (response as List).map((json) => Livro.fromJson(json)).toList();
  }

  // Add a book
  Future<void> adicionar(Livro livro, File? fileToUpload) async {
    String? capaUrl = livro.capa;

    if (fileToUpload != null) {
      // Upload image to Supabase Storage bucket 'book-covers'
      final fileExtension = fileToUpload.path.split('.').last;
      final filePath = 'covers/${livro.id}.$fileExtension';

      await _client.storage.from('book-covers').upload(
            filePath,
            fileToUpload,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      capaUrl = _client.storage.from('book-covers').getPublicUrl(filePath);
    }

    final data = livro.toJson();
    data['capa'] = capaUrl;
    // Map criadoEm to DB naming criado_em
    data['criado_em'] = data.remove('criado_em');

    await _client.from('livros').insert(data);
  }

  // Update a book
  Future<void> atualizar(Livro livro, File? fileToUpload) async {
    String? capaUrl = livro.capa;

    if (fileToUpload != null) {
      final fileExtension = fileToUpload.path.split('.').last;
      final filePath = 'covers/${livro.id}.$fileExtension';

      await _client.storage.from('book-covers').upload(
            filePath,
            fileToUpload,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      capaUrl = _client.storage.from('book-covers').getPublicUrl(filePath);
    }

    final data = livro.toJson();
    data['capa'] = capaUrl;
    data['criado_em'] = data.remove('criado_em');

    await _client.from('livros').update(data).eq('id', livro.id);
  }

  // Delete a book
  Future<void> remover(String id) async {
    // Delete from DB first
    await _client.from('livros').delete().eq('id', id);

    // Delete image from storage (ignore failures if image didn't exist)
    try {
      // Typically the covers are covers/id.jpg or covers/id.png. We'll search and remove covers/id.* if possible,
      // or try to parse from the URL. Let's delete the covers/id.png and covers/id.jpg
      await _client.storage.from('book-covers').remove(['covers/$id.jpg', 'covers/$id.png', 'covers/$id.jpeg']);
    } catch (_) {}
  }
}
