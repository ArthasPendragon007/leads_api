import 'package:leads_api/src/modules/leads/dto/lead_contagem_dto.dart';
import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/modules/leads/service/i_leads_comercial_service.dart' show ILeadsComercialService;
import 'package:vaden/vaden.dart';

@Scope(BindType.instance)
@Service()
class LeadsComercialService implements ILeadsComercialService {
  final ILeadsComercialRepository _repository;

  LeadsComercialService(this._repository);
  Future<List<LeadsComercialDto>> getAllPaginado({
    required int pagina,
    required int limit,
    String? fonte,
    String? interesse,
    String? status,
    String? busca,
  }) async {

    fonte = (fonte != null && fonte.trim().isNotEmpty) ? fonte.trim() : null;
    interesse = (interesse != null && interesse.trim().isNotEmpty) ? interesse.trim() : null;
    status = (status != null && status.trim().isNotEmpty) ? status.trim() : null;
    busca = (busca != null && busca.trim().isNotEmpty) ? busca.trim() : null;

    return await _repository.getAllPaginado(
      pagina: pagina,
      limit: limit,
      fonte: fonte,
      interesse: interesse,
      status: status,
      busca: busca,
    );
  }


Future<void> update(LeadsComercialDto dto) async {
    await _repository.update(dto);
    return;
  }

  Future<LeadContagemDto> getCount({
    required int limit,
    String? fonte,
    String? interesse,
    String? status,
    String? busca,
  }) async {

    fonte = (fonte != null && fonte.trim().isNotEmpty) ? fonte.trim() : null;
    interesse = (interesse != null && interesse.trim().isNotEmpty) ? interesse.trim() : null;
    status = (status != null && status.trim().isNotEmpty) ? status.trim() : null;
    busca = (busca != null && busca.trim().isNotEmpty) ? busca.trim() : null;

    return await _repository.getCount(limit: limit, fonte: fonte, interesse: interesse, status: status, busca: busca);
  }
}

