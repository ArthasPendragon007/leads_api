import 'package:leads_api/src/modules/leads/dto/lead_contagem_dto.dart';
import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/shared/database/database.dart';
import 'package:vaden/vaden.dart';

@Scope(BindType.instance)
@Repository()
class LeadsComercialRepository implements ILeadsComercialRepository {
  final Database _database;

  static const String _tableName = 'leads_comercial';
  String get _getIdColumn => 'id_${_tableName}';

  LeadsComercialRepository(this._database);

  @override
  Future<void> update(LeadsComercialDto dto) async {
    await _database.query(
      sql: '''
        UPDATE $_tableName SET
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
          parceiro = @parceiro,
          cidade = @cidade
        WHERE $_getIdColumn = @id;
      ''',
      parameters: _updateParams(dto),
    );
  }

  Map<String, dynamic> _updateParams(LeadsComercialDto dto) => {
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
    'cidade': dto.cidade,
  };

  @override
  Future<List<LeadsComercialDto>> getAllPaginado({
    required int pagina,
    required int limit,
    String? fonte,
    String? interesse,
    String? status,
    String? busca,
  }) async {
    final offset = pagina * limit;
    final filtros = {
      'fonte': fonte,
      'interesse': interesse,
      'status': status,
    };

    final whereData = _buildWhereClause(filtros, busca);
    final sql = '''
      SELECT 
        $_getIdColumn, 
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
        cidade
      FROM $_tableName
      ${whereData.where}
      ORDER BY data_hora DESC
      LIMIT @limit OFFSET @offset;
    ''';

    final result = await _database.query(
      sql: sql,
      parameters: {...whereData.params, 'limit': limit, 'offset': offset},
    );

    return result.map(fromMap).toList();
  }

  @override
  Future<LeadContagemDto> getCount({
    required int limit,
    String? fonte,
    String? interesse,
    String? status,
    String? busca,
  }) async {
    final totalCountsQuery = '''
    SELECT
      COUNT(*) FILTER (WHERE status = @status) AS total_pendentes,
      COUNT(*) FILTER (WHERE interesse = 'Revenda') AS total_revenda,
      COUNT(*) FILTER (WHERE interesse = 'Utilização') AS total_utilizacao
    FROM $_tableName
    WHERE status = @status;
  ''';
    final totalCountsResult =
    await _database.query(sql: totalCountsQuery, parameters: {'status': status});
    final totalCountsRow = totalCountsResult.first;

    final filtros = {
      'fonte': fonte,
      'interesse': interesse,
      'status': status,
    };
    final whereData = _buildWhereClause(filtros, busca);
    final filteredCountQuery = '''
    SELECT COUNT($_getIdColumn) AS total_filtrados
    FROM $_tableName
    ${whereData.where};
  ''';
    final filteredCountResult =
    await _database.query(sql: filteredCountQuery, parameters: whereData.params);
    final filteredCountRow = filteredCountResult.first;

    final totalFiltrados = filteredCountRow['total_filtrados'] as int? ?? 0;
    final pageTotal = (totalFiltrados / limit).ceil();

    return LeadContagemDto(
      totalStatus: totalCountsRow['total_pendentes'] as int? ?? 0,
      revenda: totalCountsRow['total_revenda'] as int? ?? 0,
      utilizacao: totalCountsRow['total_utilizacao'] as int? ?? 0,
      qntLeadsFiltrado: totalFiltrados,
      pageTotal: pageTotal,
    );
  }

  LeadsComercialDto fromMap(Map<String, dynamic> map) {
    return LeadsComercialDto(
      id: map[_getIdColumn],
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
      cidade: map['cidade'],
    );
  }

  // --- helpers ---

  _WhereData _buildWhereClause(Map<String, dynamic?> filtros, String? busca) {
    final clauses = <String>[];
    final params = <String, dynamic>{};

    _applyExactFilters(filtros, clauses, params);
    _applyFullTextSearch(busca, clauses, params);

    final where = clauses.isNotEmpty ? 'WHERE ${clauses.join(' AND ')}' : '';
    return _WhereData(where, params);
  }

  final Map<String, FilterApplier> _customFilters = {
    'fonte': (key, value, clauses, params) {
      if (value   == 'outros') {
        clauses.add("fonte NOT IN ('Instagram', 'Facebook', 'Google')");
      } else {
        clauses.add('fonte = @fonte');
        params['fonte'] = value;
      }
    },
  };

  void _applyExactFilters(
      Map<String, dynamic?> filtros,
      List<String> clauses,
      Map<String, dynamic> params,
      ) {
    for (final entry in filtros.entries) {
      final value = entry.value;
      if (value == null || value.toString().trim().isEmpty) continue;

      final customFilter = _customFilters[entry.key];
      if (customFilter != null) {
        customFilter(entry.key, value, clauses, params);
      } else {
        clauses.add('${entry.key} = @${entry.key}');
        params[entry.key] = value;
      }
    }
  }

  void _applyFullTextSearch(
      String? busca,
      List<String> clauses,
      Map<String, dynamic> params,
      ) {
    if (busca == null || busca.trim().isEmpty) return;

    final termoDeBuscaNumerico = busca.replaceAll(RegExp(r'[^0-9]'), '');
    final termoDeBuscaTexto = busca.trim();

    final searchClauses = <String>[];

    searchClauses.add('''
      (nome ILIKE @buscaText OR email ILIKE @buscaText)
    ''');
    params['buscaText'] = '%$termoDeBuscaTexto%';

    if (termoDeBuscaNumerico.isNotEmpty) {
      searchClauses.add('''
        (REGEXP_REPLACE(telefone, '[^0-9]', '', 'g') ILIKE @buscaNumerico OR
        REGEXP_REPLACE(cnpj, '[^0-9]', '', 'g') ILIKE @buscaNumerico)
      ''');
      params['buscaNumerico'] = '%$termoDeBuscaNumerico%';
    }

    searchClauses.add('''
      (TO_CHAR(data_hora, 'DD/MM/YYYY') ILIKE @buscaData OR
      TO_CHAR(data_hora, 'YYYY-MM-DD') ILIKE @buscaData)
    ''');
    params['buscaData'] = '%$termoDeBuscaTexto%';

    const camposGenericos = [
      'origem',
      'fonte',
      'meio',
      'anuncio',
      'interesse',
      'status',
      'parceiro',
      'cidade'
    ];
    final likeClauses =
    camposGenericos.map((c) => '$c ILIKE @buscaText').toList();
    searchClauses.add('(${likeClauses.join(' OR ')})');

    clauses.add('(${searchClauses.join(' OR ')})');
  }
}

class _WhereData {
  final String where;
  final Map<String, dynamic> params;
  _WhereData(this.where, this.params);
}
typedef FilterApplier = void Function(
    String key,
    dynamic value,
    List<String> clauses,
    Map<String, dynamic> params,
    );