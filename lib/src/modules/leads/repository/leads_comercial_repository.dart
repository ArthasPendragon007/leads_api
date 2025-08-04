import 'package:leads_api/src/modules/leads/dto/leads_comercial_dto.dart';
import 'package:leads_api/src/modules/leads/repository/i_leads_comercial_repository.dart';
import 'package:leads_api/src/shared/database/database.dart';
import 'package:vaden/vaden.dart';

@Scope(BindType.instance)
@Repository()
class LeadsComercialRepository implements ILeadsComercialRepository {
  final Database _database;

  String get _getTableName => 'leads_comercial';

  LeadsComercialRepository(this._database);

  Future<void> update(LeadsComercialDto dto) async {
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
        anuncio = @anuncio
      WHERE id_${_getTableName} = @id;
    ''',
      parameters: {
        'id': dto.id,
        'data_hora': dto.dataHora,
        'nome': dto.nome,
        'email': dto.email,
        'cnpj': dto.cnpj,
        'telefone': dto.telefone,
        'interesse': dto.interesse,
        'fonte': dto.fonte,
        'meio': dto.meio,
        'anuncio': dto.anuncio,
      },
    );
  }  Future<List<LeadsComercialDto>> getAllPaginado({required int pagina, required int limit, String? fonte, String? interesse, String? status}) async {
    int offset = pagina * limit;

    final filtros = {'fonte': fonte, 'interesse': interesse,'status': status};

    final filtroResult = buildWhereClauseAndParams(filtros);
    final whereClause = filtroResult['where'] as String;
    final params = filtroResult['params'] as Map<String, dynamic>;

    params.addAll({'limit': limit, 'offset': offset});

    final sql = '''
    SELECT 
      id_${_getTableName}, 
      data_hora, 
      nome, 
      email, 
      cnpj, 
      telefone,
      status,
      interesse, 
      fonte, 
      meio, 
      anuncio
    FROM $_getTableName
    $whereClause
    ORDER BY id_${_getTableName} ASC
    LIMIT @limit OFFSET @offset;
  ''';

    final result = await _database.query(sql: sql, parameters: params).then((rows) => rows.map((map) => fromMap(map)).toList());

    return result;
  }

  Map<String, dynamic> buildWhereClauseAndParams(Map<String, dynamic?> filtros) {
    final clauses = <String>[];
    final parameters = <String, dynamic>{};

    for (final entry in filtros.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value != null && value.toString().trim().isNotEmpty) {
        clauses.add('$key = @$key');
        parameters[key] = value;
      }
    }

    final where = clauses.isNotEmpty ? 'WHERE ${clauses.join(' AND ')}' : '';

    return {'where': where, 'params': parameters};
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
    );
}

