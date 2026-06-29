import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/livro.dart';
import '../services/supabase_service.dart';

class AddBookTab extends StatefulWidget {
  final VoidCallback onBookAdded;

  const AddBookTab({super.key, required this.onBookAdded});

  @override
  State<AddBookTab> createState() => _AddBookTabState();
}

class _AddBookTabState extends State<AddBookTab> {
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _idiomaController = TextEditingController();
  final _generoController = TextEditingController();
  final _tagsController = TextEditingController();
  final _capaUrlController = TextEditingController();
  final _linkController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _capaUrlController.clear(); // Clear URL if physical image selected
      });
    }
  }

  void _useUrl() {
    if (_capaUrlController.text.trim().isNotEmpty) {
      setState(() {
        _imageFile = null; // Clear physical file if URL is loaded
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capa carregada pela URL'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _salvarLivro() async {
    final titulo = _tituloController.text.trim();
    final autor = _autorController.text.trim();

    if (titulo.isEmpty || autor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha Título e Autor.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final id = const Uuid().v4();
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final novoLivro = Livro(
        id: id,
        titulo: titulo,
        autor: autor,
        idioma: _idiomaController.text.trim(),
        genero: _generoController.text.trim(),
        tags: tags,
        link: _linkController.text.trim().isEmpty ? null : _linkController.text.trim(),
        capa: _capaUrlController.text.trim().isEmpty ? null : _capaUrlController.text.trim(),
        criadoEm: DateTime.now(),
      );

      await SupabaseService.instance.adicionar(novoLivro, _imageFile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Livro adicionado à biblioteca'),
            ],
          ),
          backgroundColor: Colors.blue,
        ),
      );

      // Clear all fields
      _tituloController.clear();
      _autorController.clear();
      _idiomaController.clear();
      _generoController.clear();
      _tagsController.clear();
      _capaUrlController.clear();
      _linkController.clear();
      setState(() {
        _imageFile = null;
      });

      widget.onBookAdded();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar livro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Livros'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Book Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações do Livro',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tituloController,
                            decoration: const InputDecoration(hintText: 'Título'),
                          ),
                          TextField(
                            controller: _autorController,
                            decoration: const InputDecoration(hintText: 'Autor'),
                          ),
                          TextField(
                            controller: _idiomaController,
                            decoration: const InputDecoration(hintText: 'Idioma'),
                          ),
                          TextField(
                            controller: _generoController,
                            decoration: const InputDecoration(hintText: 'Gênero'),
                          ),
                          TextField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              hintText: 'Tags (separadas por vírgula)',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cover Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Capa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_imageFile != null) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _imageFile!,
                                  height: 150,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: _pickImage,
                            child: const Text('Escolher imagem'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _capaUrlController,
                            decoration: const InputDecoration(
                              hintText: 'Cole a URL da capa',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: _useUrl,
                            child: const Text('Usar URL'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _linkController,
                            decoration: const InputDecoration(hintText: 'Link do ebook'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                          onPressed: _salvarLivro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC8A04B), // dourado
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Salvar Livro'),
                        ),
                                                ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
