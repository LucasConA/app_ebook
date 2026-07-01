import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/livro.dart';
import '../models/enums/status_leitura.dart';
import '../services/supabase_service.dart';

class AddBookController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  final tituloController = TextEditingController();
  final autoresController = TextEditingController();
  final idiomaController = TextEditingController();
  final generoController = TextEditingController();
  final tagsController = TextEditingController();
  final capaUrlController = TextEditingController();
  final linkController = TextEditingController();

  File? _imageFile;
  StatusLeitura _status = StatusLeitura.naFila;
  bool _isLoading = false;

  File? get imageFile => _imageFile;
  StatusLeitura get status => _status;
  bool get isLoading => _isLoading;

  void setStatus(StatusLeitura novoStatus) {
    _status = novoStatus;
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
    idiomaController.clear();
    generoController.clear();
    tagsController.clear();
    capaUrlController.clear();
    linkController.clear();
    _imageFile = null;
    _status = StatusLeitura.naFila;
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
