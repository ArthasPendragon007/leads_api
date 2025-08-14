import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/shared/database/database.dart';
import 'package:vaden/vaden.dart';

import '../dto/lead_contagem_dto.dart';

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
          parceiro = @parceiro
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
        anuncio
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
    final filtros = {
      'fonte': fonte,
      'status': status,
    };

    final whereData = _buildWhereClause(filtros, busca);
    final sql = '''
      SELECT
        COUNT(*) FILTER (WHERE status = @status) AS total_pendentes,
        COUNT(*) FILTER (WHERE interesse = 'Revenda') AS total_revenda,
        COUNT(*) FILTER (WHERE interesse = 'Utilização') AS total_utilizacao,
        COUNT($_getIdColumn) AS total_filtrados
      FROM $_tableName
      ${whereData.where};
    ''';

    final result = await _database.query(sql: sql, parameters: whereData.params);
    final row = result.first;

    final totalFiltrados = row['total_filtrados'] as int? ?? 0;
    final pageTotal = (totalFiltrados / limit).ceil();

    return LeadContagemDto(
      ativo: row['total_pendentes'] as int? ?? 0,
      revenda: row['total_revenda'] as int? ?? 0,
      utilizacao: row['total_utilizacao'] as int? ?? 0,
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

  void _applyExactFilters(
      Map<String, dynamic?> filtros,
      List<String> clauses,
      Map<String, dynamic> params,
      ) {
    for (final entry in filtros.entries) {
      final value = entry.value;
      if (value != null && value.toString().trim().isNotEmpty) {
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

    const campos = [
      'nome', 'email', 'cnpj', 'telefone', 'origem',
      'fonte', 'meio', 'anuncio', 'interesse', 'status', 'parceiro'
    ];

    final likeClauses = campos.map((c) => '$c ILIKE @buscaLike').toList();
    clauses.add('(${likeClauses.join(' OR ')})');
    params['buscaLike'] = '%$busca%';
  }
}

class _WhereData {
  final String where;
  final Map<String, dynamic> params;
  _WhereData(this.where, this.params);
}
