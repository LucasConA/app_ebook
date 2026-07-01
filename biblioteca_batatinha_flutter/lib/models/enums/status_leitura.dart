enum StatusLeitura {
  naoIniciado('não iniciado', 'Não Iniciado'),
  lido('lido', 'Lido'),
  naFila('na_fila', 'Na Fila'),
  larguei('larguei', 'Larguei');

  final String value;
  final String label;

  const StatusLeitura(this.value, this.label);

  static StatusLeitura fromValue(String? value) {
    if (value == null) return StatusLeitura.naFila;
    return StatusLeitura.values.firstWhere(
      (s) => s.value == value,
      orElse: () => StatusLeitura.naFila,
    );
  }
}
