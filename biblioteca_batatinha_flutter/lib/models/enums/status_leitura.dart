enum StatusLeitura {
  lendo('lendo', 'Lendo'),
  naFila('na_fila', 'Na Fila'),
  lido('lido', 'Lido'),
  larguei('larguei', 'Larguei'),
  indefinido('indefinido', 'Indefinido');

  final String value;
  final String label;

  const StatusLeitura(this.value, this.label);

  static StatusLeitura fromValue(String? value) {
    if (value == null) return StatusLeitura.indefinido;
    if (value == 'não iniciado') return StatusLeitura.indefinido;
    return StatusLeitura.values.firstWhere(
      (s) => s.value == value,
      orElse: () => StatusLeitura.indefinido,
    );
  }

  static List<StatusLeitura> get orderedList => [
        StatusLeitura.lendo,
        StatusLeitura.naFila,
        StatusLeitura.lido,
        StatusLeitura.larguei,
        StatusLeitura.indefinido,
      ];
}
