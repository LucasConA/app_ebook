import 'package:flutter/foundation.dart';
import '../models/livro.dart';
import '../models/enums/status_leitura.dart';
import '../services/supabase_service.dart';

class LibraryController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<Livro> _todosLivros = [];
  List<Livro> _livrosFiltrados = [];
  String _ordemSelecionada = 'recente';
  StatusLeitura? _filtroStatus;
  bool _isLoading = false;
  String? _erro;

  List<Livro> get livros => _livrosFiltrados;
  String get ordemSelecionada => _ordemSelecionada;
  StatusLeitura? get filtroStatus => _filtroStatus;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<void> carregarLivros() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _todosLivros = await _service.listar();
      _aplicarFiltroEOrdem();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void ordenar(String ordem) {
    _ordemSelecionada = ordem;
    _aplicarFiltroEOrdem();
    notifyListeners();
  }

  void filtrarPorStatus(StatusLeitura? status) {
    _filtroStatus = status;
    _aplicarFiltroEOrdem();
    notifyListeners();
  }

  Future<void> removerLivro(String id) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.remover(id);
      _todosLivros.removeWhere((l) => l.id == id);
      _aplicarFiltroEOrdem();
    } catch (e) {
      _erro = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _aplicarFiltroEOrdem() {
    // Filter
    if (_filtroStatus != null) {
      _livrosFiltrados = _todosLivros
          .where((l) => l.status == _filtroStatus)
          .toList();
    } else {
      _livrosFiltrados = List.from(_todosLivros);
    }

    // Sort
    switch (_ordemSelecionada) {
      case 'recente':
        _livrosFiltrados.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
        break;
      case 'antigo':
        _livrosFiltrados.sort((a, b) => a.criadoEm.compareTo(b.criadoEm));
        break;
      case 'az':
        _livrosFiltrados.sort(
            (a, b) => a.titulo.toLowerCase().compareTo(b.titulo.toLowerCase()));
        break;
      case 'za':
        _livrosFiltrados.sort(
            (a, b) => b.titulo.toLowerCase().compareTo(a.titulo.toLowerCase()));
        break;
    }
  }
}
