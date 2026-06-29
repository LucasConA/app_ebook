class Livro {
  final String id;
  final String titulo;
  final String autor;
  final String idioma;
  final String genero;
  final List<String> tags;
  final String? link;
  final String? capa; // Will store the public URL of the cover image
  final DateTime criadoEm;

  Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.idioma,
    required this.genero,
    required this.tags,
    this.link,
    this.capa,
    required this.criadoEm,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      idioma: (json['idioma'] as String?) ?? '',
      genero: (json['genero'] as String?) ?? '',
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : <String>[],
      link: json['link'] as String?,
      capa: json['capa'] as String?,
      criadoEm: DateTime.parse(json['criado_em'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'idioma': idioma,
      'genero': genero,
      'tags': tags,
      'link': link,
      'capa': capa,
      'criado_em': criadoEm.toIso8601String(),
    };
  }
}
