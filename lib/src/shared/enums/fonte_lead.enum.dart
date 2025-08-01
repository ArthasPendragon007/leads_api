enum FonteLead {
  instagram,
  google,
  facebook;

  String get label {
    switch (this) {
      case FonteLead.instagram:
        return 'Instagram';
      case FonteLead.google:
        return 'Google';
      case FonteLead.facebook:
        return 'Facebook';
    }
  }

  static FonteLead? fromString(String? value) {
    if (value == null) return null;
    return FonteLead.values.firstWhere(
          (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => FonteLead.instagram,
    );
  }
}
