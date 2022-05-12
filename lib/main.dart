import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

final request =
    Uri.parse('https://api.hgbrasil.com/finance?format=json&key=35d008e7');

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

void main() async {
  runApp(
    MaterialApp(
      home: const Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
          hintStyle: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double? dolar;
  double? euro;

  void _realChanged(String text) {
    if(text.isEmpty){
      _clearAll('real');
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real/dolar!).toStringAsFixed(2);
    euroController.text = (real/euro!).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty){
      _clearAll('dolar');
      return;
    }
    realController.text = (double.parse(text) * dolar!).toStringAsFixed(2);
    euroController.text = (double.parse(realController.text)/euro!).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty){
      _clearAll('euro');
      return;
    }
    realController.text = (double.parse(text) * euro!).toStringAsFixed(2);
    dolarController.text = (double.parse(realController.text)/dolar!).toStringAsFixed(2);
  }

  void _clearAll(moeda){
    switch(moeda){
      case 'real':
        dolarController.text = '';
        euroController.text = '';
        break;
      case 'dolar':
        realController.text = '';
        euroController.text = '';
        break;
      case 'euro':
        realController.text = '';
        dolarController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "\$ Conversor \$",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando dados...',
                  style: TextStyle(color: Colors.amber, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao carrregar dados :(',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.amber,
                      ),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: (value) {
      f(value);
    },
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
