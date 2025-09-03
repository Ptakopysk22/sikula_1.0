import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class PridaniKorekce extends StatelessWidget {
  final Polozka zobrazovanaPolozka;
  final TextEditingController realneKusyController = TextEditingController();
  final TextEditingController poznamkaController = TextEditingController();

  PridaniKorekce({super.key, required this.zobrazovanaPolozka});

  late List seznamPolozek;
  late List seznamKonzumentu;
  List<String> nazvyPolozek = [];
  List<String> prezdivky = [];
  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  PolozkyController polozkyController = PolozkyController();
  KonzumentController konzumentController = KonzumentController();

  _pridejKorekci(BuildContext context) async {
    int? realneKusy = int.tryParse(realneKusyController.text);
    if (realneKusy == null) {
      return Zprava(text: 'Realných kusů musí být celé číslo');
    } else {
      String stavKorekce = await polozkyController.pridejKorekci(
          zobrazovanaPolozka, realneKusy, poznamkaController.text);

      Zprava zprava = spravceZprav.nastavZpravu(stavKorekce);
      return zprava;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korekce'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          Zprava zprava;
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            zprava = await _pridejKorekci(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == "Korekce přidána") {
              context.pop(true);
            }
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text('${zobrazovanaPolozka.nazev}(${zobrazovanaPolozka.id})'),
                  const SizedBox(height: 10),
                  Text(
                      'Domnělých kusů: ${zobrazovanaPolozka.zbyvajiciKusy} ks'),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: realneKusyController,
                      napoveda: 'Zadej reálný počet kusů',
                      chybovka: 'Zadej reálný počet kusů ve sklípku'),
                  const SizedBox(height: 25),
                  TextovePole(
                      textController: poznamkaController,
                      napoveda: 'Zadej poznámku',
                      chybovka: 'Zadej poznámku',
                      isRequired: true),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
