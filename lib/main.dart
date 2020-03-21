import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=9ed6b057";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void clearAll(){
    this.realController.clear();
    this.dolarController.clear();
    this.euroController.clear();
  }

  void changeReal(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/this.dolar).toStringAsFixed(2);
    euroController.text = (real/this.euro).toStringAsFixed(2);
  }

  void changeDolar(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (this.dolar * dolar).toStringAsFixed(2);
    euroController.text = ((this.dolar * dolar)/euro).toStringAsFixed(2);
  }

  void changeEuro(String text){
    if(text.isEmpty){
      clearAll();
      return;
    }
    double euro = double.parse(text);
    realController.text = (this.euro * euro).toStringAsFixed(2);
    dolarController.text = ((this.euro * euro)/this.dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor de Moedas \$"),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao Carregar Dados :(",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on, color: Colors.amber, size: 150.0,
                        ),
                        Divider(),
                        buildTextField("Reais", "R\$", realController, changeReal),
                        Divider(),
                        buildTextField("Dólares", "US\$", dolarController, changeDolar),
                        Divider(),
                        buildTextField("Euro", "€", euroController, changeEuro)
                      ],
                    ),
                  )
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String currency, String symbol, TextEditingController controller, Function change) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: currency,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: symbol
    ),
    style: TextStyle(color: Colors.amber, fontSize: 20.0),
    onChanged: change,
    keyboardType: TextInputType.number,
  );
}