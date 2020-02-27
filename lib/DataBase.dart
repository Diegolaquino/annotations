import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'annotation.dart';

class DataBase {

  static final String table = "annotations";
  static final DataBase _dataBase = DataBase._internal();
  Database _db;

  factory DataBase(){
    return _dataBase;
  }

  DataBase._internal();

  get db async{
    if( _db != null ){
      return _db;
    }
    else{
      _db = await inicializarDB();
      return _db;
    }
  }

  inicializarDB() async{
    final caminhoBancoDeDados = await getDatabasesPath();
    final localBancoDeDados = join(caminhoBancoDeDados, "annotations_database");

    var db = await openDatabase(localBancoDeDados, version: 1, onCreate: _onCreate);

    return db;
  }

  _onCreate(Database db, int version) async{
    String sql = "Create Table $table ( id Integer PRIMARY KEY AUTOINCREMENT, titulo VARCHAR, descricao TEXT, data DATETIME )";

    await db.execute(sql);
  }

  Future<int> salvarAnotacao(Annotation anotacao) async{
    var bancoDeDados = await db;
    int resultado = await bancoDeDados.insert(table, anotacao.toMap());

    return resultado;
  }

  recuperarAnotacoes() async{
    var bancoDados = await db;
    String sql = "SELECT * FROM $table ORDER BY data DESC";
    List anotacoes = await bancoDados.rawQuery( sql );
    return anotacoes;
  }

  deletarAnotacao(int id) async{
    var bancoDados = await db;
    String sql = "delete from $table where id = $id";
    await bancoDados.execute( sql );
  }


}