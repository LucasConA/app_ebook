import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/livro.dart';
import '../models/enums/status_leitura.dart';
import '../services/supabase_service.dart';

class LivroDetalheDialog extends StatefulWidget {
  final Livro livro;
  final VoidCallback onUpdated;

  const LivroDetalheDialog({
    super.key,
    required this.livro,
    required this.onUpdated,
  });

  @override
  State<LivroDetalheDialog> createState() => _LivroDetalheDialogState();
}

class _LivroDetalheDialogState extends State<LivroDetalheDialog> {
  late Livro _livroEditando;
  bool _modoEdicao = false;
  late TextEditingController _tituloCtrl;
  late TextEditingController _autoresCtrl;
  late TextEditingController _idiomaCtrl;
  late TextEditingController _generoCtrl;
  late TextEditingController _tagsCtrl;
  late TextEditingController _linkCtrl;
  late StatusLeitura _statusSelecionado;

  File? _newImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  List<String> _generos = [];

  @override
  void initState() {
    super.initState();
    _livroEditando = widget.livro;
    _initControllers();
    _carregarGeneros();
  }

  Future<void> _carregarGeneros() async {
    final list = await SupabaseService.instance.listarGeneros();
    if (mounted) {
      setState(() {
        _generos = list;
      });
    }
  }

  void _initControllers() {
    _tituloCtrl = TextEditingController(text: _livroEditando.titulo);
    _autoresCtrl = TextEditingController(text: _livroEditando.autores.join(', '));
    _idiomaCtrl = TextEditingController(text: _livroEditando.idioma);
    _generoCtrl = TextEditingController(text: _livroEditando.genero);
    _tagsCtrl = TextEditingController(text: _livroEditando.tags.join(', '));
    _linkCtrl = TextEditingController(text: _livroEditando.link ?? '');
    _statusSelecionado = _livroEditando.status;
  }

  Future<void> _pickNewImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _abrirLink(String url) async {
    String trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return;

    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      trimmedUrl = 'https://$trimmedUrl';
    }

    final uri = Uri.parse(trimmedUrl);
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir o link: $e')),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty || _autoresCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final autores = _autoresCtrl.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      final tags = _tagsCtrl.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final livroAtualizado = _livroEditando.copyWith(
        titulo: _tituloCtrl.text.trim(),
        autores: autores,
        idioma: _idiomaCtrl.text.trim(),
        genero: _generoCtrl.text.trim(),
        tags: tags,
        link: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
        status: _livroEditando.status,
      );

      await SupabaseService.instance.atualizar(livroAtualizado, _newImageFile);

      widget.onUpdated();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
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



  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _modoEdicao ? _buildEditMode() : _buildViewMode(),
              ),
            ),
    );
  }

  Widget _buildViewMode() {
    return Column(
      key: const ValueKey('viewMode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Detalhes do Livro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: _livroEditando.capa != null
                ? CachedNetworkImage(
                    imageUrl: _livroEditando.capa!,
                    height: 200,
                    width: 140,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 200,
                      width: 140,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/placeholder-book.jpg',
                      height: 200,
                      width: 140,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/placeholder-book.jpg',
                    height: 200,
                    width: 140,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _livroEditando.titulo,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          'por ${_livroEditando.autoresFormatados}',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Status badge
        const Text(
          'Status de leitura',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<StatusLeitura>(
          initialValue: _livroEditando.status,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF1E4738),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF1E4738),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xFFF6F3ED),
          ),

          dropdownColor: const Color(0xFFF6F3ED),

          iconEnabledColor: const Color(0xFF1E4738),

          style: const TextStyle(
            color: Color(0xFF1E4738),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          items: StatusLeitura.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.label),
            );
          }).toList(),
          onChanged: (novoStatus) async {
            if (novoStatus == null) return;

            final atualizado = _livroEditando.copyWith(
              status: novoStatus,
            );

            await SupabaseService.instance.atualizar(atualizado, null);

            setState(() {
              _livroEditando = atualizado;
              _statusSelecionado = novoStatus;
            });

            widget.onUpdated();
          },
        ),
        const Divider(height: 32),
        if (_livroEditando.genero.isNotEmpty) ...[
          Text('Gênero: ${_livroEditando.genero}', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
        ],
        if (_livroEditando.idioma.isNotEmpty) ...[
          Text('Idioma: ${_livroEditando.idioma}', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
        ],
        if (_livroEditando.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: _livroEditando.tags
                .map((tag) => Chip(
                      label: Text(tag, style: const TextStyle(fontSize: 12)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
        ],
        const SizedBox(height: 24),
        if (_livroEditando.link != null && _livroEditando.link!.isNotEmpty) ...[
          ElevatedButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('Acessar Ebook / Link'),
            onPressed: () => _abrirLink(_livroEditando.link!),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
          onPressed: () => setState(() => _modoEdicao = true),
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      key: const ValueKey('editMode'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Editar Livro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        const Text(
          'Título',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _tituloCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Autores (separados por vírgula)',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _autoresCtrl,
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
          initialValue: ['Português', 'Inglês', 'Espanhol'].contains(_idiomaCtrl.text)
              ? _idiomaCtrl.text
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
              _idiomaCtrl.text = val;
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
          initialValue: _generos.contains(_generoCtrl.text)
              ? _generoCtrl.text
              : (_generos.isNotEmpty ? _generos.first : null),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _generos.map((gen) {
            return DropdownMenuItem<String>(
              value: gen,
              child: Text(gen),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              _generoCtrl.text = val;
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
          controller: _tagsCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Link do ebook',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _linkCtrl,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Status de leitura',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E4738)),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<StatusLeitura>(
          initialValue: _statusSelecionado,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: StatusLeitura.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.label),
            );
          }).toList(),
          onChanged: (novoStatus) {
            if (novoStatus == null) return;
            setState(() {
              _statusSelecionado = novoStatus;
              _livroEditando = _livroEditando.copyWith(
                status: novoStatus,
              );
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _pickNewImage,
                child: Text(_newImageFile != null ? 'Nova Capa Selecionada' : 'Alterar Capa'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _newImageFile = null;
                    _modoEdicao = false;
                    _initControllers();
                  });
                },
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
