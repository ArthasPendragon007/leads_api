import 'package:vaden/vaden.dart';
import 'package:diacritic/diacritic.dart';

@DTO()
class LeadsComercialDto {
  final int id;
  final DateTime dataHora;
  final String? nome;
  final String? email;
  final String? cnpj;
  final String? telefone;
  final InteresseLead interesse;
  final String? origem;
  final String? fonte;
  final String? meio;
  final String? anuncio;
  final StatusLead status;
  final String? parceiro;
  final String? cidade;

  LeadsComercialDto({
    required this.id,
    required this.dataHora,
    required this.nome,
    required this.email,
    required this.cnpj,
    required this.telefone,
    required this.interesse,
    required this.origem,
    required this.fonte,
    required this.meio,
    required this.anuncio,
    required this.status,
    required this.parceiro,
    required this.cidade,
  });
}

enum InteresseLead {
  utilizacao,
  revenda;

  static InteresseLead fromName(String value) {
    final normalized = removeDiacritics(value.toLowerCase());

    return InteresseLead.values.firstWhere(
          (e) => e.name == normalized,
      orElse: () => InteresseLead.utilizacao,
    );
  }

  String toDb() {
    switch (this) {
      case InteresseLead.utilizacao:
        return 'Utilização';
      case InteresseLead.revenda:
        return 'Revenda';
    }
  }
}

enum StatusLead {
  pendente,
  concluido;

  static StatusLead fromName(String value) {
    final normalized = removeDiacritics(value.toLowerCase());

    return StatusLead.values.firstWhere(
          (e) => e.name == normalized,
      orElse: () => StatusLead.pendente,
    );
  }

}



