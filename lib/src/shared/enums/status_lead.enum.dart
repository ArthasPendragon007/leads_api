enum StatusLead {
  pendente,
  concluido;

  String get label {
    switch (this) {
      case StatusLead.pendente:
        return 'Pendente';
      case StatusLead.concluido:
        return 'Concluído';
    }
  }

  static StatusLead? fromString(String? value) {
    if (value == null) return null;
    return StatusLead.values.firstWhere(
          (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => StatusLead.pendente,
    );
  }
}
