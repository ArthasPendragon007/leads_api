import 'package:vaden/vaden.dart';

@DTO()
class LeadContagemDto {
  final int totalStatus;
  final int revenda;
  final int utilizacao;
  final int qntLeadsFiltrado;
  final int pageTotal;

  LeadContagemDto({
    required this.totalStatus,
    required this.revenda,
    required this.utilizacao,
    required this.qntLeadsFiltrado,
    required this.pageTotal,
  });
}
