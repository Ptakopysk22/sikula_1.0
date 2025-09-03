import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/DatabazeController.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/Radek.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/komponenty/Tlacitko.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/Zaloha.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class SpravaKreditu extends StatefulWidget {
  final Zaloha zobrazovanaZaloha;
  late final TextEditingController castkaController;
  late final SingleValueDropDownController ucetController;
  late final TextEditingController poznamkaController;
  late String? ucet;

  SpravaKreditu({super.key, required this.zobrazovanaZaloha}) {
    castkaController = TextEditingController(
        text: zobrazovanaZaloha.castka == null
            ? ''
            : zobrazovanaZaloha.castka.toString());
    DropDownValueModel? aktualniUcet = zobrazovanaZaloha.ucet != null
        ? DropDownValueModel(
            name: zobrazovanaZaloha.ucet!.nazev,
            value: zobrazovanaZaloha.ucet!.nazev,
          )
        : null;
    ucetController = SingleValueDropDownController(data: aktualniUcet);
    ucet = aktualniUcet?.value;
    poznamkaController =
        TextEditingController(text: zobrazovanaZaloha.poznamka);
  }

  @override
  State<SpravaKreditu> createState() => _SpravaKredituState();
}

class _SpravaKredituState extends State<SpravaKreditu> {
  late List<Ucet> ucty;

  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();

  KonzumentController konzumentController = KonzumentController();

  DatabazeController databazeController = DatabazeController();

  _pridejZalohu(BuildContext context) async {
    String stavZalohy = await konzumentController.pridejZalohu(
        widget.zobrazovanaZaloha.konzument!,
        double.tryParse(widget.castkaController.text.replaceAll(',', '.')),
        _vratUcetDleNazvu(widget.ucet),
        widget.poznamkaController.text);
    Zprava zprava = spravceZprav.nastavZpravu(stavZalohy);
    return zprava;
  }

  _upravZalohu(BuildContext context) async {
    String stavZalohy = await konzumentController.upravZalohu(
        widget.zobrazovanaZaloha.id,
        widget.zobrazovanaZaloha.konzument!,
        double.tryParse(widget.castkaController.text.replaceAll(',', '.')),
        _vratUcetDleNazvu(widget.ucet),
         widget.poznamkaController.text);
    Zprava zprava = spravceZprav.nastavZpravu(stavZalohy);
    return zprava;
  }

  Ucet? _vratUcetDleNazvu(String? nazevUctu) {
    for (var ucet in ucty) {
      if (ucet.nazev == nazevUctu) {
        return ucet;
      }
    }
    return null;
  }

  Future<List<String>> _vratNazvyUctu(BuildContext context) async {
    ucty = await databazeController.vratUcty();
    List<String> nazvyUctu = [];
    for (var ucet in ucty) {
      nazvyUctu.add(ucet.nazev);
    }
    return nazvyUctu;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratNazvyUctu(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> nazvyUctu = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: widget.zobrazovanaZaloha.id != 1000
                    ? Text('Záloha ID ${widget.zobrazovanaZaloha.id}')
                    : const Text('Správa kreditu'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  Zprava zprava;
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.zobrazovanaZaloha.id != 1000) {
                      zprava = await _upravZalohu(context);
                    } else {
                      zprava = await _pridejZalohu(context);
                    }
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(zprava.text)));
                    if (zprava.text == 'Záloha přidána' ||
                        zprava.text == 'Záloha upravena') {
                      Navigator.pop(context, true);
                    }
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Radek(
                              text: widget
                                  .zobrazovanaZaloha.konzument!.prezdivka),
                          Radek(
                              text:
                                  'Aktuální kredit: ${widget.zobrazovanaZaloha.konzument!.kredit} Kč'),
                          const SizedBox(
                            height: 15,
                          ),
                          CiselnePole(
                              cisloContoller: widget.castkaController,
                              napoveda: 'Zadej částku',
                              chybovka: 'Zadej částku'),
                          const SizedBox(height: 25),
                          VyberZMoznosti(
                              moznostiContoller: widget.ucetController,
                              moznosti: nazvyUctu,
                              napoveda: 'Vyber účet',
                              chybovka: 'Vyber účet transakce',
                              onChanged: (String? value) {
                                widget.ucet = value!;
                              }),
                          const SizedBox(height: 25),
                          TextovePole(
                              textController: widget.poznamkaController,
                              napoveda: 'Zadej poznámku',
                              chybovka: 'Zadej poznámku',
                              isRequired: widget.zobrazovanaZaloha.id != 1000),
                          const SizedBox(
                            height: 110,
                          ),
                          if (widget.zobrazovanaZaloha.id == 1000)
                            Tlacitko(
                                poZmacknuti: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final result = await context.push(
                                        '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta/spravaKreditu/QRplatbaZalohy',
                                        extra: Zaloha(
                                            id: widget.zobrazovanaZaloha.id,
                                            konzument: widget
                                                .zobrazovanaZaloha.konzument,
                                            datumAcas: null,
                                            castka: double.tryParse(widget
                                                .castkaController.text
                                                .replaceAll(',', '.')),
                                            ucet:
                                                _vratUcetDleNazvu(widget.ucet),
                                            vyridil: null,
                                            poznamka: null));
                                    if (result == true) {
                                      Navigator.pop(context, true);
                                    }
                                  }
                                },
                                text: 'Zobraz QR'),
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

