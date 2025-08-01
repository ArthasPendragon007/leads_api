import 'dart:convert';

import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/service/i_leads_comercial_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Leads', description: 'Visualiza e edita os leads do sistema')
@Controller('/leads')
class OperadorController {
  final ILeadsComercialService _service;

  OperadorController(this._service);

  @ApiOperation(summary: 'Lista de todos os Leads', description: 'Cadastra um novo operador no sistema ou Atualiza um existente')
  @ApiResponse(200, description: 'Lista entregue com sucesso', content: ApiContent(type: 'application/json', schema: List<LeadsComercialDto>))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Get('/pegarTudoPaginado')
  Future<Response> getAllPaginado(@Query("PageNumber") int pagina, [@Query("PageSize") int? limit = 10,@Query("FiltroFonte") String? fonte,@Query("FiltroInteresse") String? interesse]) async {
    limit = limit ?? 10;
    try{
      final leads = await _service.getAllPaginado(pagina: pagina, limit: limit, fonte: fonte, interesse: interesse);
      return Response.ok(jsonEncode(leads), headers: {'Content-Type': 'application/json'});
    } catch(e) {
      return Response.badRequest(body: jsonEncode({'error': e.toString()}), headers: {'Content-Type': 'application/json'});

    }
  }

  @ApiOperation(summary: 'Atualizar valores do Lead', description: 'Atualiza um Lead já existente no sistema')
  @ApiResponse(200, description: 'Operador cadastrado com sucesso', content: ApiContent(type: 'application/json', schema: LeadsComercialDto))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Put('/atualizar')
  Future<Response> Atualizar(@Body() LeadsComercialDto dto) async {
    try {
  await _service.update(dto);
  return Response.ok(jsonEncode({}));
  } catch (e) {
  return Response.badRequest(body: jsonEncode({'error': e.toString()}), headers: {'Content-Type': 'application/json'});
  }
}
}