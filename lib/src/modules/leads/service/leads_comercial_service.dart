import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/modules/leads/service/i_leads_comercial_service.dart' show ILeadsComercialService;
import 'package:vaden/vaden.dart';

@Scope(BindType.instance)
@Service()
class LeadsComercialService implements ILeadsComercialService {
  final ILeadsComercialRepository _repository;

  LeadsComercialService(this._repository);
  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse, String? status}) async {
    return await _repository.getAllPaginado(pagina: pagina, limit: limit, fonte: fonte, interesse: interesse, status: status);
}

Future update(LeadsComercialDto dto) async {
    await _repository.update(dto);
    return;
  }
}

