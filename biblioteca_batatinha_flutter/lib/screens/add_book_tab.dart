import 'package:flutter/material.dart';
import '../models/enums/status_leitura.dart';
import '../controllers/add_book_controller.dart';

class AddBookTab extends StatefulWidget {
  final VoidCallback onBookAdded;

  const AddBookTab({super.key, required this.onBookAdded});

  @override
  State<AddBookTab> createState() => _AddBookTabState();
}

class _AddBookTabState extends State<AddBookTab> {
  final AddBookController _controller = AddBookController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _salvar() async {
    final erro = _controller.validar();
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      await _controller.salvarLivro();

      if (mounted) {
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
      }

      widget.onBookAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar livro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _usarUrl() {
    _controller.usarUrl();
    if (_controller.capaUrlController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capa carregada pela URL'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Livros'),
      ),
      body: _controller.isLoading
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
                            controller: _controller.tituloController,
                            decoration: const InputDecoration(hintText: 'Título'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller.autoresController,
                            decoration: const InputDecoration(
                              hintText: 'Autores (separados por vírgula)',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller.idiomaController,
                            decoration: const InputDecoration(hintText: 'Idioma'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller.generoController,
                            decoration: const InputDecoration(hintText: 'Gênero'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller.tagsController,
                            decoration: const InputDecoration(
                              hintText: 'Tags (separadas por vírgula)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Status selector
        
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
                          if (_controller.imageFile != null) ...[
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.file(
                                  _controller.imageFile!,
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
                            onPressed: () => _controller.pickImage(),
                            child: const Text('Escolher imagem'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller.capaUrlController,
                            decoration: const InputDecoration(
                              hintText: 'Cole a URL da capa',
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: _usarUrl,
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
                            controller: _controller.linkController,
                            decoration: const InputDecoration(hintText: 'Link do ebook'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _salvar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC8A04B),
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
