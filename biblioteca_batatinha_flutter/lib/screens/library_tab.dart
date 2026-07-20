import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/livro.dart';
import '../models/enums/status_leitura.dart';
import '../controllers/library_controller.dart';
import 'livro_detalhe_dialog.dart';

class LibraryTab extends StatefulWidget {
  const LibraryTab({super.key});

  @override
  State<LibraryTab> createState() => LibraryTabState();
}

class LibraryTabState extends State<LibraryTab> {
  final LibraryController _controller = LibraryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.carregarLivros();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});

    if (_controller.erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${_controller.erro}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void carregarLivros() => _controller.carregarLivros();

  Future<void> _confirmarRemocao(String id) async {
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
      _controller.removerLivro(id);
    }
  }

  void _abrirDetalhes(Livro livro) {
    showDialog(
      context: context,
      builder: (context) => LivroDetalheDialog(
        livro: livro,
        onUpdated: () => _controller.carregarLivros(),
      ),
    );
  }

  Color _statusColor(StatusLeitura status) {
    switch (status) {
      case StatusLeitura.lendo:
        return const Color(0xFF2196F3);
      case StatusLeitura.naFila:
        return const Color(0xFFC8A04B);
      case StatusLeitura.lido:
        return const Color(0xFF2E7D32);
      case StatusLeitura.larguei:
        return Colors.red.shade700;
      case StatusLeitura.indefinido:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar',
            onPressed: () => _controller.carregarLivros(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sort + Filter bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      // Sort dropdown
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              'Ordenar',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String>(
                              value: _controller.ordemSelecionada,
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              onChanged: (v) {
                                if (v != null) _controller.ordenar(v);
                              },
                              items: const [
                                 DropdownMenuItem(value: 'recente', child: Text('Recente')),
                                 DropdownMenuItem(value: 'antigo', child: Text('Antigo')),
                                 DropdownMenuItem(value: 'az', child: Text('A-Z')),
                                 DropdownMenuItem(value: 'za', child: Text('Z-A')),
                                 DropdownMenuItem(value: 'status', child: Text('Status')),
                               ],
                            ),
                          ],
                        ),
                      ),
                      // Status filter
                      DropdownButton<StatusLeitura?>(
                        value: _controller.filtroStatus,
                        underline: const SizedBox.shrink(),
                        isDense: true,
                        hint: const Text('Status'),
                        onChanged: (v) => _controller.filtrarPorStatus(v),
                        items: [
                          const DropdownMenuItem<StatusLeitura?>(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ...StatusLeitura.orderedList.map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.label),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Book Grid
                Expanded(
                  child: _controller.livros.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum livro encontrado.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: _controller.livros.length,
                          itemBuilder: (context, index) {
                            final livro = _controller.livros[index];
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
          // Cover
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
                  // Delete button
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _confirmarRemocao(livro.id),
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
                  // Status badge
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      color: _statusColor(livro.status).withValues(alpha: 0.85),
                      child: Text(
                        livro.status.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Title
          Text(
            livro.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          // Authors
          Text(
            livro.autoresFormatados,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
