enum InteresseLead {
  utilizacao,
  revenda;

  String get label {
    switch (this) {
      case InteresseLead.utilizacao:
        return 'Utilização';
      case InteresseLead.revenda:
        return 'Revenda';
    }
  }

  static InteresseLead? fromString(String? value) {
    if (value == null) return null;
    return InteresseLead.values.firstWhere(
          (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => InteresseLead.utilizacao,
    );
  }
}
