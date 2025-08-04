import 'package:vaden/vaden.dart';

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
  });

  factory LeadsComercialDto.fromMap(Map<String, dynamic> map) {
    return LeadsComercialDto(
      id: map['id_leads_comercial'],
      dataHora: DateTime.parse(map['data_hora']),
      nome: map['nome'],
      email: map['email'],
      cnpj: map['cnpj'],
      telefone: map['telefone'],
      interesse: InteresseLead.fromName(map['interesse']),
      origem: map['origem'],
      fonte: map['fonte'],
      meio: map['meio'],
      anuncio: map['anuncio'],
      status: StatusLead.fromName(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_leads_comercial': id,
      'data_hora': dataHora.toIso8601String(),
      'nome': nome,
      'email': email,
      'cnpj': cnpj,
      'telefone': telefone,
      'interesse': interesse.name,
      'origem': origem,
      'fonte': fonte,
      'meio': meio,
      'anuncio': anuncio,
      'status': status.name,
    };
  }
}

enum InteresseLead {
  utilizacao,
  revenda;


  static InteresseLead fromName(String value) {
    return InteresseLead.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => InteresseLead.utilizacao,
    );
  }
}

enum StatusLead {
  pendente,
  concluido;

  static StatusLead fromName(String value) {
    return StatusLead.values.firstWhere(
          (e) => e.name == value.toLowerCase(),
      orElse: () => StatusLead.pendente,
    );
  }
}


