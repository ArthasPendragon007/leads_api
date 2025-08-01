import 'package:postgres/postgres.dart';
import 'package:vaden/vaden.dart';

@Component()
class Database {
  final Connection _connection;

  Database(this._connection);

  Future<List<Map<String, dynamic>>> query({required String sql, Map<String, dynamic>? parameters, TxSession? txn}) async {
    final result = await _executeQuery(query: sql, parameters: parameters, txn: txn);
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Result> _executeQuery({required String query, Map<String, dynamic>? parameters, TxSession? txn}) async {
    final conn = txn ?? _connection;
    try {
      return await conn.execute(Sql.named(query), parameters: parameters);
    } on ServerException catch (e) {
      throw _tratarException(e);
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Exception _tratarException(ServerException e) {
    if (e.code == '3D000') {
      return Exception('Banco de dados não encontrado.');
    } else if (e.code == '28P01') {
      return Exception('Usuário ou senha inválidos.');
    } else if (e.code == '28P01') {
      return Exception('Conexão recusada.');
    } else {
      return e;
    }
  }

  Future<void> update({required String tableName, required Map<String, dynamic> values, TxSession? txn}) async {
    final filteredValues = Map<String, dynamic>.from(values);

    final idColumn = 'id_$tableName';

    if (filteredValues[idColumn] == null) {
      filteredValues.remove(idColumn);
    }

    final columns = filteredValues.keys.join(', ');
    final params = filteredValues.keys.map((e) => '@$e').join(', ');

    String query;

    if (filteredValues.containsKey(idColumn)) {
      final updateSet = filteredValues.keys.where((key) => key != idColumn).map((key) => '$key = EXCLUDED.$key').join(', ');

      query = '''
      INSERT INTO $tableName ($columns)
      VALUES ($params)
      ON CONFLICT ($idColumn) DO UPDATE SET $updateSet
    ''';
    } else {
    throw Exception("oii");
    }

    await _executeQuery(query: query, parameters: filteredValues, txn: txn);
  }
}
