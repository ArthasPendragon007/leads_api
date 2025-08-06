import 'package:vaden/vaden.dart';

@DTO()
class LeadContagemDto {
  final int ativo;
  final int revenda;
  final int utilizacao;

  LeadContagemDto({
    required this.ativo,
    required this.revenda,
    required this.utilizacao,
  });
}
