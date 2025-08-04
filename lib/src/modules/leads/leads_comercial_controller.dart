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
  Future<List<LeadsComercialDto>> getAllPaginado(@Query("PageNumber") int pagina, [@Query("PageSize") int? limit, @Query("Filtro Fonte") String? fonte, @Query("Filtro Interesse") String? interesse, @Query("Filtro Status") String? status]) async {
    limit = limit ?? 10;
    pagina -= 1;
      return await _service.getAllPaginado(pagina: pagina, limit: limit, fonte: fonte, interesse: interesse,status: status);
    }

  @ApiOperation(summary: 'Atualizar valores do Lead', description: 'Atualiza um Lead já existente no sistema')
  @ApiResponse(200, description: 'Operador cadastrado com sucesso', content: ApiContent(type: 'application/json', schema: LeadsComercialDto))
  @ApiResponse(400, description: 'Requisição inválida', content: ApiContent(type: 'application/json'))
  @ApiResponse(401, description: 'Não autorizado', content: ApiContent(type: 'application/json'))
  @ApiResponse(500, description: 'Erro interno do servidor', content: ApiContent(type: 'application/json'))
  @Put('/atualizar')
  Future<LeadsComercialDto> Atualizar(@Body() LeadsComercialDto dto) async {
    return await _service.update(dto);
  }
}