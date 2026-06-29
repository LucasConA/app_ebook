import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/livro.dart';
import '../services/supabase_service.dart';
import 'livro_detalhe_dialog.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => LibraryTabState();
}

class LibraryTabState extends State<LibraryTab> {
  List<Livro> _livros = [];
  String _ordemSelecionada = 'recente';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    carregarLivros();
  }

  Future<void> carregarLivros() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final livros = await SupabaseService.instance.listar();
      setState(() {
        _livros = livros;
        _ordenarLivros();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar biblioteca: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _ordenarLivros() {
    setState(() {
      switch (_ordemSelecionada) {
        case 'recente':
          _livros.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
          break;
        case 'antigo':
          _livros.sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
          break;
        case 'az':
          _livros.sort((a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
          break;
        case 'za':
          _livros.sort((a, b) => b.titulo.toLowerCase().compareTo(a.titulo.toLowerCase()));
          break;
      }
    });
  }

  Future<void> _removerLivro(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Livro'),
        content: const Text('Deseja realmente remover este livro da biblioteca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await SupabaseService.instance.remover(id);
        await carregarLivros();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _abrirDetalhes(Livro livro) {
    showDialog(
      context: context,
      builder: (context) => LivroDetalheDialog(
        livro: livro,
        onUpdated: () => carregarLivros(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarLivros,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Ordering selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ordenar por',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      DropdownButton<String>(
                        value: _ordemSelecionada,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _ordemSelecionada = newValue;
                              _ordenarLivros();
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'recente', child: Text('Mais recente')),
                          DropdownMenuItem(value: 'antigo', child: Text('Mais antigo')),
                          DropdownMenuItem(value: 'az', child: Text('Título A-Z')),
                          DropdownMenuItem(value: 'za', child: Text('Título Z-A')),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Book Grid
                Expanded(
                  child: _livros.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum livro cadastrado.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _livros.length,
                          itemBuilder: (context, index) {
                            final livro = _livros[index];
                            return _buildBookGridItem(livro);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildBookGridItem(Livro livro) {
    return GestureDetector(
      onTap: () => _abrirDetalhes(livro),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Capa wrapper
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  livro.capa != null
                      ? CachedNetworkImage(
                          imageUrl: livro.capa!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/placeholder-book.jpg',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/placeholder-book.jpg',
                          fit: BoxFit.cover,
                        ),
                  // Delete overlay button (top right)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _removerLivro(livro.id),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Book Title
          Text(
            livro.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
