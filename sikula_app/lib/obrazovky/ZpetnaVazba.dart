import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/ZpetnaVazbaController.dart';
import 'package:sikula/komponenty/Radek.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class ZpetnaVazba extends StatelessWidget {
  ZpetnaVazba({super.key});
  TextEditingController textController = TextEditingController();
  ZpetnaVazbaController zpetnaVazbaController = ZpetnaVazbaController();
  SpravceZprav spravceZprav = SpravceZprav();
  final _formKey = GlobalKey<FormState>();

  Future<Zprava> _pridejZpetnouVazbu() async {
    String stavZpetneVazby = await zpetnaVazbaController.pridejZpetnouVazbu(
        AktualniVedouci.vedouci!, textController.text);
    Zprava zprava = spravceZprav.nastavZpravu(stavZpetneVazby);
    return zprava;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zpětná vazba'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            _formKey.currentState!.save();
            Zprava zprava = await _pridejZpetnouVazbu();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == 'Děkuji za zpětnou vazbu') {
              context.go('/domovska');
            }
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Radek(text: 'Prostor pro jakékoliv '),
                  const Radek(text: 'přimomínky.Vítám pozitivní i '),
                  const Radek(text: 'negativní poznámky. V případě '),
                  const Radek(text: 'popisování problému popiš '),
                  const Radek(text: 'podrobně všechny okolnosti.'),
                  const SizedBox(height: 10),
                  TextovePole(
                    textController: textController,
                    napoveda: 'Napiš jakoukoliv připomínku',
                    chybovka: 'Připomínka nesmí být prázdná',
                    isRequired: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
