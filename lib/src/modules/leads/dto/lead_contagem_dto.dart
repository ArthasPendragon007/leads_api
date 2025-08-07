import 'package:vaden/vaden.dart';

@DTO()
class LeadContagemDto {
  final int ativo;
  final int revenda;
  final int utilizacao;
  final int pageTotal;

  LeadContagemDto({
    required this.ativo,
    required this.revenda,
    required this.utilizacao,
    required this.pageTotal,
  });
}
