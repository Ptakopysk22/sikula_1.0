import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class ManualniCarkovani extends StatelessWidget {
  final Konzument zobrazovanyKonzument;
  late final TextEditingController kusyController;
  late final SingleValueDropDownController polozkaController;
  //zde nesmí být final!
  late String? polozka;
  late String polozkaScenou;
  late Zprava zprava;

  ManualniCarkovani({super.key, required this.zobrazovanyKonzument}) {
    kusyController = TextEditingController(text: '1');
    polozkaController = SingleValueDropDownController(data: null);
  }

  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  PolozkyController polozkyController = PolozkyController();

  _nacarkujuPolozku(BuildContext context) async {
    if (AktualniVedouci.vedouci!.konzument == null) {
      return zprava = Zprava(text: 'Na čárkování musíš být konzument!');
    } else if (int.tryParse(kusyController.text) == null) {
      return Zprava(text: 'Počet kusů musí být celé číslo');
    } else if (_vratPolozkuDleNazvu(polozka)!.zbyvajiciKusy! <
        int.tryParse(kusyController.text)!) {
      return zprava = Zprava(
          text:
              'Překročen maximální počet (max: ${_vratPolozkuDleNazvu(polozka)!.zbyvajiciKusy!} ks)');
    } else {
      String stavCarkovani = await polozkyController.nacarkujuPolozku(
          zobrazovanyKonzument,
          AktualniVedouci.vedouci!.konzument,
          _vratPolozkuDleNazvu(polozka),
          int.tryParse(kusyController.text));
      Zprava zprava = spravceZprav.nastavZpravu(stavCarkovani);
      return zprava;
    }
  }

  late List<Polozka> nabidkaPolozek;

  Polozka? _vratPolozkuDleNazvu(String? nazevPolozky) {
    for (var polozka in nabidkaPolozek) {
      if (polozka.nazev == nazevPolozky) {
        return polozka;
      }
    }
    return null;
  }

  Future<List<String>> _vratNabidkuPolozek(BuildContext context) async {
    nabidkaPolozek = await polozkyController.vratNabidkuPolozek();
    List<String> nazvyPolozek = [];
    for (var polozka in nabidkaPolozek) {
      nazvyPolozek.add('${polozka.nazev!} (\$${polozka.prodejniCena})');
    }
    return nazvyPolozek;
  }

  _vratPolozkuZpolozkyScenou(String polozkaScenou) {
    List<String> casti = polozkaScenou.split("(");
    int delka = casti[0].length;
    polozka = casti[0].substring(0, delka - 1);
    return polozka;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratNabidkuPolozek(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> nazvyPolozek = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Manuální',
                      style: TextStyle(fontSize: 22),
                    ),
                    Text(
                      'čárkování',
                      style: TextStyle(fontSize: 22),
                    )
                  ],
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
                    zprava = await _nacarkujuPolozku(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(zprava.text)));
                    if (zprava.text == 'Položka načárkována' ||
                        zprava.text == "Záznam upraven") {
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
                          Text('Konzument: ${zobrazovanyKonzument.prezdivka}'),
                          const SizedBox(
                            height: 20,
                          ),
                          VyberZMoznosti(
                              moznostiContoller: polozkaController,
                              moznosti: nazvyPolozek,
                              napoveda: 'Vyber položku',
                              chybovka: 'Vyber položku',
                              onChanged: (String? value) {
                                polozkaScenou = value!;
                                polozka =
                                    _vratPolozkuZpolozkyScenou(polozkaScenou);
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          CiselnePole(
                              cisloContoller: kusyController,
                              napoveda: 'Počet kusů',
                              chybovka: 'Zadej počet kusů')
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
