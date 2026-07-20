import 'package:flutter/material.dart';
import '../models/enums/status_leitura.dart';
import '../controllers/add_book_controller.dart';
import '../services/google_books_service.dart';

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
    _controller.carregarDados();
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

  List<String> _obterTagsSugeridas(String input) {
    if (input.isEmpty) return [];
    final parts = input.split(',');
    final lastPart = parts.last.trim().toLowerCase();
    if (lastPart.isEmpty) return [];

    final existingInInput = parts.sublist(0, parts.length - 1).map((p) => p.trim().toLowerCase()).toSet();

    return _controller.todasTags
        .where((tag) =>
            tag.toLowerCase().contains(lastPart) &&
            !existingInInput.contains(tag.toLowerCase()))
        .take(5)
        .toList();
  }

  void _adicionarTagSugerida(String tag) {
    final text = _controller.tagsController.text;
    final parts = text.split(',');
    if (parts.isNotEmpty) {
      parts[parts.length - 1] = ' $tag';
    }
    _controller.tagsController.text = '${parts.join(',')}, ';
    _controller.tagsController.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.tagsController.text.length),
    );
    setState(() {});
  }

  Future<void> _buscarNoGoogleBooks() async {
    final searchCtrl = TextEditingController(text: _controller.tituloController.text);
    List<GoogleBookModel> searchResults = [];
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Buscar no Google Books'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Digite o título ou autor...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            setDialogState(() {
                              isSearching = true;
                              searchResults = [];
                            });
                            try {
                              final books = await GoogleBooksService.search(searchCtrl.text);
                              setDialogState(() {
                                searchResults = books;
                                isSearching = false;
                              });
                            } catch (_) {
                              setDialogState(() {
                                isSearching = false;
                              });
                            }
                          },
                        ),
                      ),
                      onSubmitted: (val) async {
                        setDialogState(() {
                          isSearching = true;
                          searchResults = [];
                        });
                        try {
                          final books = await GoogleBooksService.search(val);
                          setDialogState(() {
                            searchResults = books;
                            isSearching = false;
                          });
                        } catch (_) {
                          setDialogState(() {
                            isSearching = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isSearching)
                      const Center(child: CircularProgressIndicator())
                    else if (searchResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum livro encontrado.'),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final book = searchResults[index];
                            return ListTile(
                              leading: book.coverUrl != null
                                  ? Image.network(
                                      book.coverUrl!,
                                      width: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.book),
                                    )
                                  : const Icon(Icons.book),
                              title: Text(book.title),
                              subtitle: Text(book.authors.join(', ')),
                              onTap: () {
                                _controller.preencherComGoogleBook(book);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Informações preenchidas!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar'),
                ),
              ],
            );
          },
        );
      },
    );
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
                           const Text(
                             'Título',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           Row(
                             children: [
                               Expanded(
                                 child: TextField(
                                   controller: _controller.tituloController,
                                   decoration: const InputDecoration(
                                     border: OutlineInputBorder(),
                                     filled: true,
                                     fillColor: Colors.white,
                                   ),
                                 ),
                               ),
                               IconButton(
                                 icon: const Icon(Icons.search, color: Color(0xFFC8A04B)),
                                 tooltip: 'Buscar no Google Books',
                                 onPressed: _buscarNoGoogleBooks,
                               ),
                             ],
                           ),
                           const SizedBox(height: 16),
                           const Text(
                             'Autores (separados por vírgula)',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           TextField(
                             controller: _controller.autoresController,
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               filled: true,
                               fillColor: Colors.white,
                             ),
                           ),
                           const SizedBox(height: 16),
                           const Text(
                             'Idioma',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           DropdownButtonFormField<String>(
                             initialValue: ['Português', 'Inglês', 'Espanhol'].contains(_controller.idiomaController.text)
                                 ? _controller.idiomaController.text
                                 : 'Português',
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               filled: true,
                               fillColor: Colors.white,
                             ),
                             items: ['Português', 'Inglês', 'Espanhol'].map((lang) {
                               return DropdownMenuItem<String>(
                                 value: lang,
                                 child: Text(lang),
                               );
                             }).toList(),
                             onChanged: (val) {
                               if (val != null) {
                                 _controller.idiomaController.text = val;
                               }
                             },
                           ),
                           const SizedBox(height: 16),
                           const Text(
                             'Gênero',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           DropdownButtonFormField<String>(
                             initialValue: _controller.generos.contains(_controller.generoController.text)
                                 ? _controller.generoController.text
                                 : (_controller.generos.isNotEmpty ? _controller.generos.first : null),
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               filled: true,
                               fillColor: Colors.white,
                             ),
                             items: _controller.generos.map((gen) {
                               return DropdownMenuItem<String>(
                                 value: gen,
                                 child: Text(gen),
                               );
                             }).toList(),
                             onChanged: (val) {
                               if (val != null) {
                                 _controller.generoController.text = val;
                               }
                             },
                           ),
                           const SizedBox(height: 16),
                           const Text(
                             'Tags (separadas por vírgula)',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           TextField(
                             controller: _controller.tagsController,
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               filled: true,
                               fillColor: Colors.white,
                             ),
                             onChanged: (val) {
                               setState(() {});
                             },
                           ),
                           Builder(
                             builder: (context) {
                               final suggestions = _obterTagsSugeridas(_controller.tagsController.text);
                               if (suggestions.isEmpty) return const SizedBox.shrink();
                               return Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Wrap(
                                   spacing: 8.0,
                                   runSpacing: 4.0,
                                   children: suggestions.map((tag) {
                                     return ActionChip(
                                       label: Text(tag, style: const TextStyle(fontSize: 12)),
                                       onPressed: () => _adicionarTagSugerida(tag),
                                       backgroundColor: const Color(0xFFF6F3ED),
                                     );
                                   }).toList(),
                                 ),
                               );
                             },
                           ),
                           const SizedBox(height: 16),
                           const Text(
                             'Status da Leitura',
                             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
                           ),
                           const SizedBox(height: 6),
                           DropdownButtonFormField<StatusLeitura>(
                             initialValue: _controller.status,
                             decoration: const InputDecoration(
                               border: OutlineInputBorder(),
                               filled: true,
                               fillColor: Colors.white,
                             ),
                             items: StatusLeitura.values.map((status) {
                               return DropdownMenuItem<StatusLeitura>(
                                 value: status,
                                 child: Text(status.label),
                               );
                             }).toList(),
                             onChanged: (novoStatus) {
                               if (novoStatus != null) {
                                 _controller.setStatus(novoStatus);
                               }
                             },
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
