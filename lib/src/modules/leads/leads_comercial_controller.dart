import 'dart:convert';

import 'package:leads_api/src/modules/leads/dto/lead_contagem_dto.dart';
import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/service/i_leads_comercial_service.dart';
import 'package:vaden/vaden.dart';

@Api(tag: 'Leads', description: 'Visualiza e edita os leads do sistema')
@Controller('/leads')
class LeadsComercialController {
  final ILeadsComercialService _service;

  LeadsComercialController(this._service);

  @ApiOperation(summary: 'Lista de todos os Leads', description: 'Lista todos os Leads do sistema com paginação e filtros')
  @ApiResponse(200, description: 'Lista entregue com sucesso', content: ApiContent(type: 'application/json', schema: List<LeadsComercialDto>))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Get('/pegarTudoPaginado')
  Future<List<LeadsComercialDto>> getAllPaginado(@Query("PageNumber") int pagina, [@Query("PageSize") int? limit, @Query("FiltroFonte") String? fonte, @Query("FiltroInteresse") String? interesse, @Query("FiltroStatus") String? status, @Query("Busca") String? busca]) async {
    limit = limit ?? 10;
    pagina -= 1;
      return await _service.getAllPaginado(pagina: pagina, limit: limit, fonte: fonte, interesse: interesse,status: status, busca: busca);
    }
  @ApiOperation(summary: 'Dados dos Leads', description: 'Visualiza a contagem de algumas colunas da tabela no sistema')
  @ApiResponse(200, description: 'Dados entregue com sucesso', content: ApiContent(type: 'application/json', schema: LeadContagemDto))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Get('/pegarDados')
  Future<LeadContagemDto> getCount() async {
    return await _service.getCount();
  }

  @ApiOperation(summary: 'Atualizar valores do Lead', description: 'Atualiza um Lead já existente no sistema')
  @ApiResponse(200, description: 'Operador cadastrado com sucesso', content: ApiContent(type: 'application/json', schema: LeadsComercialDto))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Put('/atualizar')
  Future<String> Atualizar(@Body() LeadsComercialDto dto) async {
    await _service.update(dto);
    return 'Lead atualizado com sucesso!';
  }
}