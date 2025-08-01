import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';

abstract class ILeadsComercialRepository {
  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse});
  Future update(LeadsComercialDto dto);
}