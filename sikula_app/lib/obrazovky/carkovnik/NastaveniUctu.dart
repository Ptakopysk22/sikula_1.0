import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/BankovniUcet.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class NastaveniUctu extends StatelessWidget {
  final BankovniUcet? bankovniUcet;
  late final TextEditingController zakladniCastController;
  late final TextEditingController kodBankyController;

  NastaveniUctu({super.key, required this.bankovniUcet}) {
    if (bankovniUcet!.zakladniCast == '' && bankovniUcet!.kodBanky == '') {
      zakladniCastController = TextEditingController(text: null);
      kodBankyController = TextEditingController(text: null);
    } else {
      zakladniCastController =
          TextEditingController(text: bankovniUcet!.zakladniCast);
      kodBankyController = TextEditingController(text: bankovniUcet!.kodBanky);
    }
  }

  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  VedouciController vedouciController = VedouciController();

  _upravUcet(BuildContext context) async {
    String stavUctu = await vedouciController.upravUcet(
        AktualniVedouci.vedouci!,
        zakladniCastController.text,
        kodBankyController.text);
    Zprava zprava = spravceZprav.nastavZpravu(stavUctu);
    return zprava;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nastavení účtu',
          style: TextStyle(fontSize: 32),
        ),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          Zprava zprava;
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            zprava = await _upravUcet(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == "Účet upraven") {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Základní část účtu:'),
                  const SizedBox(
                    height: 8,
                  ),
                  TextovePole(
                      textController: zakladniCastController,
                      napoveda: 'Zadej základní část účtu',
                      chybovka: 'Zadej základní část účtu včetně přečíslý'),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text('Kód banky:'),
                  const SizedBox(
                    height: 8,
                  ),
                  TextovePole(
                      textController: kodBankyController,
                      napoveda: 'Zadej kod banky',
                      chybovka: 'Zadej kod banky'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
