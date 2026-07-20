import 'enums/status_leitura.dart';

class Livro {
  final String id;
  final String titulo;
  final List<String> autores;
  final String idioma;
  final String genero;
  final List<String> tags;
  final String? link;
  final String? capa;
  final StatusLeitura status;
  final DateTime criadoEm;

  Livro({
    required this.id,
    required this.titulo,
    required this.autores,
    required this.idioma,
    required this.genero,
    required this.tags,
    this.link,
    this.capa,
    this.status = StatusLeitura.indefinido,
    required this.criadoEm,
  });

  String get autoresFormatados => autores.join(', ');

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      autores: json['autores'] != null
          ? List<String>.from(json['autores'] as List)
          : <String>[],
      idioma: (json['idioma'] as String?) ?? '',
      genero: (json['genero'] as String?) ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : <String>[],
      link: json['link'] as String?,
      capa: json['capa'] as String?,
      status: StatusLeitura.fromValue(json['status'] as String?),
      criadoEm: DateTime.parse(json['criado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autores': autores,
      'idioma': idioma,
      'genero': genero,
      'tags': tags,
      'link': link,
      'capa': capa,
      'status': status.value,
      'criado_em': criadoEm.toIso8601String(),
    };
  }

  Livro copyWith({
    String? id,
    String? titulo,
    List<String>? autores,
    String? idioma,
    String? genero,
    List<String>? tags,
    String? link,
    String? capa,
    StatusLeitura? status,
    DateTime? criadoEm,
  }) {
    return Livro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autores: autores ?? this.autores,
      idioma: idioma ?? this.idioma,
      genero: genero ?? this.genero,
      tags: tags ?? this.tags,
      link: link ?? this.link,
      capa: capa ?? this.capa,
      status: status ?? this.status,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }
}
