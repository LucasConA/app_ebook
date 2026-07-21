import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/livro.dart';
import '../models/enums/status_leitura.dart';
import '../services/supabase_service.dart';
import '../services/google_books_service.dart';

class AddBookController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  final tituloController = TextEditingController();
  final autoresController = TextEditingController();
  final idiomaController = TextEditingController(text: 'Português');
  final generoController = TextEditingController();
  final tagsController = TextEditingController();
  final capaUrlController = TextEditingController();
  final linkController = TextEditingController();

  File? _imageFile;
  StatusLeitura _status = StatusLeitura.indefinido;
  bool _isLoading = false;

  List<String> _generos = [];
  List<String> get generos => _generos;

  List<String> _todasTags = [];
  List<String> get todasTags => _todasTags;

  File? get imageFile => _imageFile;
  StatusLeitura get status => _status;
  bool get isLoading => _isLoading;

  void setStatus(StatusLeitura novoStatus) {
    _status = novoStatus;
    notifyListeners();
  }

  Future<void> carregarDados() async {
    try {
      _generos = await _service.listarGeneros();
      _todasTags = await _service.listarTodasTags();
      if (_generos.isNotEmpty && generoController.text.isEmpty) {
        generoController.text = _generos.first;
      }
      notifyListeners();
    } catch (_) {}
  }

  void preencherComGoogleBook(GoogleBookModel book) {
    tituloController.text = book.title;
    autoresController.text = book.authors.join(', ');
    if (book.genre != null && book.genre!.isNotEmpty) {
      final match = _generos.firstWhere(
        (g) => g.toLowerCase() == book.genre!.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        generoController.text = match;
      } else {
        final fallback = _generos.firstWhere(
          (g) => book.genre!.toLowerCase().contains(g.toLowerCase()) || g.toLowerCase().contains(book.genre!.toLowerCase()),
          orElse: () => _generos.isNotEmpty ? _generos.first : '',
        );
        if (fallback.isNotEmpty) {
          generoController.text = fallback;
        }
      }
    }
    if (book.language != null) {
      idiomaController.text = book.language!;
    } else {
      idiomaController.text = 'Português';
    }
    if (book.infoLink != null) {
      linkController.text = book.infoLink!;
    }
    if (book.coverUrl != null) {
      capaUrlController.text = book.coverUrl!;
      _imageFile = null;
    }
    notifyListeners();
  }

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      _imageFile = File(pickedFile.path);
      capaUrlController.clear();
      notifyListeners();
    }
  }

  void usarUrl() {
    if (capaUrlController.text.trim().isNotEmpty) {
      _imageFile = null;
      notifyListeners();
    }
  }

  String? validar() {
    if (tituloController.text.trim().isEmpty) {
      return 'Por favor, preencha o Título.';
    }
    if (autoresController.text.trim().isEmpty) {
      return 'Por favor, preencha pelo menos um Autor.';
    }
    return null;
  }

  Future<bool> salvarLivro() async {
    final erro = validar();
    if (erro != null) throw Exception(erro);

    _isLoading = true;
    notifyListeners();

    try {
      final id = const Uuid().v4();

      final autores = autoresController.text
          .split(',')
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList();

      final tags = tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final novoLivro = Livro(
        id: id,
        titulo: tituloController.text.trim(),
        autores: autores,
        idioma: idiomaController.text.trim(),
        genero: generoController.text.trim(),
        tags: tags,
        link: linkController.text.trim().isEmpty
            ? null
            : linkController.text.trim(),
        capa: capaUrlController.text.trim().isEmpty
            ? null
            : capaUrlController.text.trim(),
        status: _status,
        criadoEm: DateTime.now(),
      );

      await _service.adicionar(novoLivro, _imageFile);
      limparFormulario();
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparFormulario() {
    tituloController.clear();
    autoresController.clear();
    idiomaController.text = 'Português';
    if (_generos.isNotEmpty) {
      generoController.text = _generos.first;
    } else {
      generoController.clear();
    }
    tagsController.clear();
    capaUrlController.clear();
    linkController.clear();
    _imageFile = null;
    _status = StatusLeitura.indefinido;
    notifyListeners();
  }

  @override
  void dispose() {
    tituloController.dispose();
    autoresController.dispose();
    idiomaController.dispose();
    generoController.dispose();
    tagsController.dispose();
    capaUrlController.dispose();
    linkController.dispose();
    super.dispose();
  }
}
