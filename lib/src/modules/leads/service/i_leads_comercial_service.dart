import 'package:leads_api/src/modules/leads/dto/lead_contagem_dto.dart';
import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';

abstract class ILeadsComercialService {
  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse, String? status, String? busca});
  Future<void> update(LeadsComercialDto dto);
  Future<LeadContagemDto> getCount({
    required int limit,
    String? fonte,
    String? interesse,
    String? status,
    String? busca,
  });
}