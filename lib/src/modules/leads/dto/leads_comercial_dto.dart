import 'package:leads_api/src/shared/enums/fonte_lead.enum.dart';
import 'package:leads_api/src/shared/enums/interesse_lead.enum.dart';
import 'package:leads_api/src/shared/enums/leads_enums.dart';

class LeadsComercialDto {
  final int id;
  final DateTime dataHora;
  final String nome;
  final String email;
  final String cnpj;
  final String telefone;
  final InteresseLead interesse;
  final String origem;
  final FonteLead fonte;
  final String meio;
  final String anuncio;
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
      interesse: InteresseLead.fromString(map['interesse'])!,
      origem: map['origem'],
      fonte: FonteLead.fromString(map['fonte'])!,
      meio: map['meio'],
      anuncio: map['anuncio'],
      status: StatusLead.fromString(map['status'])!,
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
      'interesse': interesse.label,
      'origem': origem,
      'fonte': fonte.label,
      'meio': meio,
      'anuncio': anuncio,
      'status': status.label,
    };
  }
}
