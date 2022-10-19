import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = "https://api.hgbrasil.com/finance?key=c32da9e7";

late final VoidCallback onChanged; // Good

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.amber),
          ),
          hintStyle: TextStyle(color: Colors.amber),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final euroController = TextEditingController();
  final dolarController = TextEditingController();

  double? dolar;
  double? euro;
  double? reais;

  void _changeReal(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar!).toStringAsFixed(2);
    euroController.text = (real / euro!).toStringAsFixed(2);
  }

  void _changeEuro(String text) {
    double euro = double.parse(text);
    dolarController.text = (this.euro! * euro / dolar!).toStringAsFixed(2);
    realController.text = (this.euro! * euro).toStringAsFixed(2);
  }

  void _changeDolar(String text) {
    double dolar = double.parse(text);
    euroController.text = (dolar * this.dolar! / euro!).toStringAsFixed(2);
    realController.text = (this.dolar! * dolar).toStringAsFixed(2);
  }

  void clear() {
    dolarController.text = '';
    realController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: clear,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: ((context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  'Carregando...',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.amber,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Erro ao Carregar dados',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];

                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildTextFild(
                              'Reais', "R\$", realController, _changeReal),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildTextFild(
                              'Dolar', 'US\$', dolarController, _changeDolar),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: buildTextFild(
                              'Euros', '€', euroController, _changeEuro),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                child: TextButton(
                                  onPressed: () {
                                    _changeReal(realController.text);
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.all(16),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      backgroundColor: Colors.amber),
                                  child: const Text(
                                    'Reais',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 25,),
                              TextButton(
                                onPressed: () {
                                  _changeEuro(euroController.text);
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.amber),
                                child: const Text(
                                  'Euros',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 25,),
                              TextButton(
                                onPressed: () {
                                  _changeDolar(dolarController.text);
                                },
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor: Colors.amber),
                                child: const Text(
                                  'Dolar',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
          }
        }),
      ),
    );
  }
}

Widget buildTextFild(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber, fontSize: 20),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(
      fontSize: 25,
      color: Colors.amber,
    ),
    //onTap: function ,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  Map teste = json.decode(response.body);
  return teste;
}
