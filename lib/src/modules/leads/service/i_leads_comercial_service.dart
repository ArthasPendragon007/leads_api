import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';

abstract class ILeadsComercialService {
  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse, String? status});
  Future update(LeadsComercialDto dto);
}