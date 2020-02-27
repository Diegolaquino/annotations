import 'package:annotations/annotation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:annotations/DataBase.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
   var _db = DataBase();
   List<Annotation> _anotacoes = List<Annotation>();
  
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();

  _exibirTelaCadastro(){
    showDialog(context: context, 
    builder:(context){
      return AlertDialog(
        title: Text("Adicionar anotação"),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _tituloController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Título",
                hintText: "Digite o título",
              ),
              cursorColor: Color(0xFF7159c1),
              
            ),
            TextField(
              controller: _descricaoController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Descrição",
                hintText: "Digite o Descrição",
              ),
            cursorColor: Color(0xFF7159c1),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.clear),
          ),
          FlatButton(
            onPressed: (){
              _salvarAnotacao(_tituloController.text, _descricaoController.text);
               Navigator.pop(context);
            },
            child: Icon(Icons.done),
          ),
        ],
      );
    }
    );
  }

  _recuperarAnotacoes() async{
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    
    List<Annotation> listaTemporaria = List<Annotation>();
    for (var item in anotacoesRecuperadas) {
      var anotacao = Annotation.fromMap( item );
      listaTemporaria.add(anotacao);
    }

    setState(() {
      _anotacoes = listaTemporaria;
    });

    listaTemporaria = null;
  }

  _salvarAnotacao(String titulo, String descricao) async {

    var anotacao = Annotation(titulo, descricao, DateTime.now().toString());
    int resultado = await _db.salvarAnotacao( anotacao );

    print("id => " + resultado.toString());

    _tituloController.clear();
    _descricaoController.clear();

    _recuperarAnotacoes();
  }

  _remove(int index) async{

    await _db.deletarAnotacao(index);

    //  setState(() {
    //   _anotacoes.removeWhere((a) => a.id == index);
    // });
  }

  @override
  void initState(){
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {

    _recuperarAnotacoes();

    return Scaffold(
      appBar: AppBar(
        title: Text("Anotações"),
        backgroundColor: Color(0xFF7159c1),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: ListView.builder(
            itemCount: _anotacoes.length,
            itemBuilder: (context, index){
              final item = _anotacoes[index];
              return Dismissible(key: Key(item.id.toString()),
               child: Card(
                child: ListTile(
                  title: Text(item.titulo),
                  subtitle: Text("${item.data} - ${item.descricao} "),

                ),
              ),
              onDismissed: (direction){
                _remove(item.id);
              }
              );
            },
            ),)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _exibirTelaCadastro();
        },
        backgroundColor: Color(0xFF7159c1),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        ),

      
    );
  }
}
