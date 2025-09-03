import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class DetailVedouciho extends StatelessWidget {
  final Vedouci zobrazovanyVedouci;
  late final TextEditingController prezdivkaController;
  late final TextEditingController emailController;
  late final SingleValueDropDownController funkceController;
  //zde nesmí být final!
  late String? funkce;

  DetailVedouciho({super.key, required this.zobrazovanyVedouci}) {
    prezdivkaController =
        TextEditingController(text: zobrazovanyVedouci.prezdivka);
    emailController = TextEditingController(text: zobrazovanyVedouci.email);
    DropDownValueModel? aktualniFunkce = zobrazovanyVedouci.funkce != null
        ? DropDownValueModel(
            name: zobrazovanyVedouci.funkce!,
            value: zobrazovanyVedouci.funkce,
          )
        : null;
    funkceController = SingleValueDropDownController(data: aktualniFunkce);
    funkce = aktualniFunkce?.value;
  }

  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  VedouciController vedouciController = VedouciController();

  _pridejVedouciho(BuildContext context) async {
    String stavVedouciho = await vedouciController.pridejVedouciho(
        prezdivkaController.text, emailController.text, funkce!);
    Zprava zprava = spravceZprav.nastavZpravu(stavVedouciho);
    return zprava;
  }

  _upravVedouciho(BuildContext context) async {
    String stavVedouciho = await vedouciController.upravVedouciho(
        zobrazovanyVedouci.id,
        prezdivkaController.text,
        emailController.text,
        funkce!);
    Zprava zprava = spravceZprav.nastavZpravu(stavVedouciho);
    return zprava;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: zobrazovanyVedouci.id != 1000
            ? Text('Vedoucí ID ${zobrazovanyVedouci.id}')
            : const Text('Nový vedoucí'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          Zprava zprava;
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            if (zobrazovanyVedouci.id != 1000) {
              zprava = await _upravVedouciho(context);
            } else {
              zprava = await _pridejVedouciho(context);
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == 'Vedoucí přidán' ||
                zprava.text == "Vedoucí upraven") {
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
                  TextovePole(
                    textController: prezdivkaController,
                    napoveda: 'Zadej přezdívku',
                    chybovka: 'Zadej přezdívku vedoucího',
                    isRequired: true,
                  ),
                  const SizedBox(height: 25),
                  TextovePole(
                    textController: emailController,
                    napoveda: 'Zadej email',
                    chybovka: 'Zadej email vedoucího',
                    isRequired: true,
                  ),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: funkceController,
                      moznosti: const ['U oddílu', 'Hospodář', 'Hlavas'],
                      napoveda: 'Vyber funkci',
                      chybovka: 'Vyber funkci pro vedoucího',
                      onChanged: (String? value) {
                        funkce = value!;
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
