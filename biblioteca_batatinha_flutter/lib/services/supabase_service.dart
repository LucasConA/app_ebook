import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livro.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._init();
  SupabaseService._init();

  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Livro>> listar() async {
    final response = await _client
        .from('livros')
        .select()
        .order('criado_em', ascending: false);

    return (response as List).map((json) => Livro.fromJson(json)).toList();
  }

  Future<void> adicionar(Livro livro, File? fileToUpload) async {
    String? capaUrl = livro.capa;

    if (fileToUpload != null) {
      capaUrl = await _uploadCapa(livro.id, fileToUpload);
    }

    final data = livro.toJson();
    data['capa'] = capaUrl;

    await _client.from('livros').insert(data);
  }

  Future<void> atualizar(Livro livro, File? fileToUpload) async {
    String? capaUrl = livro.capa;

    if (fileToUpload != null) {
      capaUrl = await _uploadCapa(livro.id, fileToUpload);
    }

    final data = livro.toJson();
    data['capa'] = capaUrl;

    await _client.from('livros').update(data).eq('id', livro.id);
  }

  Future<void> remover(String id) async {
    await _client.from('livros').delete().eq('id', id);

    try {
      await _client.storage
          .from('book-covers')
          .remove(['covers/$id.jpg', 'covers/$id.png', 'covers/$id.jpeg']);
    } catch (_) {}
  }

  Future<String> _uploadCapa(String livroId, File file) async {
    final fileExtension = file.path.split('.').last;
    final filePath = 'covers/$livroId.$fileExtension';

    await _client.storage.from('book-covers').upload(
          filePath,
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return _client.storage.from('book-covers').getPublicUrl(filePath);
  }

  Future<List<String>> listarGeneros() async {
    try {
      final response = await _client.from('generos').select('nome').order('nome');
      return (response as List).map((item) => item['nome'] as String).toList();
    } catch (e) {
      return [
        'Ficção contemporânea',
        'Romance',
        'Suspense',
        'Fantasia',
        'Ficção científica',
        'Clássicos',
        'Biografias',
        'Ficção histórica',
        'Terror',
        'Policial',
        'História',
        'Filosofia',
        'Ciência'
      ]..sort();
    }
  }

  Future<List<String>> listarTodasTags() async {
    try {
      final response = await _client.from('livros').select('tags');
      final Set<String> uniqueTags = {};
      for (var row in (response as List)) {
        if (row['tags'] != null) {
          for (var tag in (row['tags'] as List)) {
            uniqueTags.add(tag.toString().trim());
          }
        }
      }
      return uniqueTags.toList()..sort();
    } catch (_) {
      return [];
    }
  }
}
