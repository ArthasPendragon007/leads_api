import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/shared/database/database.dart';
import 'package:vaden/vaden.dart';

import '../dto/lead_contagem_dto.dart';

@Scope(BindType.instance)
@Repository()
class LeadsComercialRepository implements ILeadsComercialRepository {
  final Database _database;

  String get _getTableName => 'leads_comercial';

  LeadsComercialRepository(this._database);

  Future<void> update(LeadsComercialDto dto) async {
    print(dto.status.name);
    await _database.query(
      sql: '''
      UPDATE $_getTableName SET
        data_hora = @data_hora,
        nome = @nome,
        email = @email,
        cnpj = @cnpj,
        telefone = @telefone,
        interesse = @interesse,
        origem = @origem,
        fonte = @fonte,
        meio = @meio,
        anuncio = @anuncio,
        status = @status,
        parceiro = @parceiro
      WHERE id_${_getTableName} = @id;
    ''',
      parameters: {
        'id': dto.id,
        'data_hora': dto.dataHora,
        'nome': dto.nome,
        'email': dto.email,
        'cnpj': dto.cnpj,
        'telefone': dto.telefone,
        'interesse': dto.interesse.toDb(),
        'fonte': dto.fonte,
        'origem': dto.origem,
        'meio': dto.meio,
        'anuncio': dto.anuncio,
        'status': dto.status.name,
        'parceiro': dto.parceiro,
      },
    );
  }

  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse, String? status, String? busca}) async {
    final offset = pagina * limit;

    // Filtros exatos
    final filtros = {
      'fonte': fonte,
      'interesse': interesse,
      'status': status,
    };

    final filtroResult = buildWhereClauseAndParams(filtros, null);
    final whereClause = filtroResult['where'] as String;
    final params = filtroResult['params'] as Map<String, dynamic>;

    params.addAll({
      'limit': limit,
      'offset': offset,
    });

    final sql = '''
    SELECT 
      id_${_getTableName}, 
      data_hora, 
      nome, 
      email, 
      cnpj, 
      telefone,
      parceiro,
      status,
      origem,
      interesse, 
      fonte, 
      meio, 
      anuncio,
      parceiro
    FROM $_getTableName
    $whereClause
    ORDER BY data_hora DESC
    LIMIT @limit OFFSET @offset;
  ''';

    final result = await _database.query(
      sql: sql,
      parameters: params,
    );

    return result.map(fromMap).toList();
  }

  Map<String, dynamic> buildWhereClauseAndParams(Map<String, dynamic?> filtros, String? busca) {
    final clauses = <String>[];
    final parameters = <String, dynamic>{};

    // Filtros exatos
    for (final entry in filtros.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value != null && value
          .toString()
          .trim()
          .isNotEmpty) {
        clauses.add('$key = @$key');
        parameters[key] = value;
      }
    }

    // Fuzzy search por nome
    if (busca != null && busca
        .trim()
        .isNotEmpty) {
      clauses.add('nome % @busca'); // Operador de similaridade (~30%)
      parameters['busca'] = busca;
    }

    final where = clauses.isNotEmpty ? 'WHERE ${clauses.join(' AND ')}' : '';

    return {
      'where': where,
      'params': parameters,
    };
  }

  LeadsComercialDto fromMap(Map<String, dynamic> map) =>
      LeadsComercialDto(
        id: map['id_leads_comercial'],
        dataHora: map['data_hora'],
        nome: map['nome'],
        email: map['email'],
        cnpj: map['cnpj'],
        telefone: map['telefone'],
        interesse: InteresseLead.fromName(map['interesse']),
        origem: map['origem'],
        fonte: map['fonte'],
        meio: map['meio'],
        anuncio: map['anuncio'],
        status: StatusLead.fromName(map['status']),
        parceiro: map['parceiro'],
      );

  Future<LeadContagemDto> getCount() async {
    final result = await _database.query(
      sql: '''
      SELECT
        COUNT(*) FILTER (WHERE status = 'pendente') AS total_pendentes,
        COUNT(*) FILTER (WHERE interesse = 'Revenda' AND status = 'pendente') AS total_revenda,
        COUNT(*) FILTER (WHERE interesse = 'Utilização' AND status = 'pendente') AS total_utilizacao
      FROM leads_comercial;
    ''',
    );

    final row = result.first;
    return LeadContagemDto(
      ativo: row['total_pendentes'] as int,
      revenda: row['total_revenda'] as int,
      utilizacao: row['total_utilizacao'] as int,
      // Preciso fazer uma Maximo de PageNumber para isso os mesmos filtros enviados para o getAllPaginado precisarão ser enviados aqui. tudo isso para que o front possa fazer a paginação corretamente, resolver amanha.
    );
  }

}


