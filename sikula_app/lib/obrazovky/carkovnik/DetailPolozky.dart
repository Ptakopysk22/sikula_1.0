import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/DatabazeController.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class DetailPolozky extends StatefulWidget {
  final Polozka zobrazovanaPolozka;
  late final TextEditingController nazevController;
  late final TextEditingController pocetKusuController;
  late final TextEditingController nakupniCenaController;
  late final TextEditingController prodejniCenaController;
  late final TextEditingController poznamkaController;
  late final SingleValueDropDownController kategorieController;
  late final SingleValueDropDownController ucetController;
  //zde nesmí být final!
  late String? kategorie;
  late String? ucet;

  DetailPolozky({super.key, required this.zobrazovanaPolozka}) {
    nazevController = TextEditingController(text: zobrazovanaPolozka.nazev);
    pocetKusuController = TextEditingController(
        text: zobrazovanaPolozka.nakoupeneKusy == null
            ? ''
            : zobrazovanaPolozka.nakoupeneKusy.toString());
    nakupniCenaController = TextEditingController(
        text: zobrazovanaPolozka.nakupniCena == null
            ? ''
            : zobrazovanaPolozka.nakupniCena.toString());
    prodejniCenaController = TextEditingController(
        text: zobrazovanaPolozka.prodejniCena == null
            ? ''
            : zobrazovanaPolozka.prodejniCena.toString());
    poznamkaController =
        TextEditingController(text: zobrazovanaPolozka.poznamka);
    DropDownValueModel? aktualniKategorie = zobrazovanaPolozka.kategorie != null
        ? DropDownValueModel(
            name: zobrazovanaPolozka.kategorie!.oznaceni,
            value: zobrazovanaPolozka.kategorie!.oznaceni,
          )
        : null;
    kategorieController =
        SingleValueDropDownController(data: aktualniKategorie);
    kategorie = aktualniKategorie?.value;
    DropDownValueModel? aktualniUcet = zobrazovanaPolozka.ucet != null
        ? DropDownValueModel(
            name: zobrazovanaPolozka.ucet!.nazev,
            value: zobrazovanaPolozka.ucet!.nazev,
          )
        : null;
    ucetController = SingleValueDropDownController(data: aktualniUcet);
    ucet = aktualniUcet?.value;
  }

  @override
  State<DetailPolozky> createState() => _DetailPolozkyState();
}

class _DetailPolozkyState extends State<DetailPolozky> {
  late List<Ucet> seznamUctu;
  late List<Kategorie> seznamKategorii;
  List<String> nazvyUctu = [];
  List<String> nazvyKategorii = [];
  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  PolozkyController polozkyController = PolozkyController();
  DatabazeController databazeController = DatabazeController();

  @override
  void initState() {
    super.initState();
    _nactiNazvyKategorii();
    _nactiNazvyUctu();
  }

  Future<void> _nactiNazvyUctu() async {
    seznamUctu = await databazeController.vratUcty();
    for (var ucet in seznamUctu) {
      nazvyUctu.add(ucet.nazev);
    }
    setState(() {});
  }

  Future<void> _nactiNazvyKategorii() async {
    seznamKategorii = await databazeController.vratSeznamKategorii();
    for (var kategorie in seznamKategorii) {
      nazvyKategorii.add(kategorie.oznaceni);
    }
    setState(() {});
  }

  Ucet? _vratUcetDleNazvu(String? nazevUctu) {
    for (var ucet in seznamUctu) {
      if (ucet.nazev == nazevUctu) {
        return ucet;
      }
    }
    return null;
  }

  Kategorie? _vratKategoriiDleNazvu(String? nazevKategorie) {
    for (var kategorie in seznamKategorii) {
      if (kategorie.oznaceni == nazevKategorie) {
        return kategorie;
      }
    }
    return null;
  }

  _pridejPolozku(BuildContext context) async {
    int? nakoupeneKusy = int.tryParse(widget.pocetKusuController.text);
    if (nakoupeneKusy == null) {
      return Zprava(text: 'Nakoupené kusy musí být celé číslo');
    } else {
      String stavPolozky = await polozkyController.pridejPolozku(
          widget.nazevController.text,
          nakoupeneKusy,
          double.tryParse(
              widget.nakupniCenaController.text.replaceAll(',', '.')),
          double.tryParse(
              widget.prodejniCenaController.text.replaceAll(',', '.')),
          _vratKategoriiDleNazvu(widget.kategorie),
          _vratUcetDleNazvu(widget.ucet),
          widget.poznamkaController.text);
      Zprava zprava = spravceZprav.nastavZpravu(stavPolozky);
      return zprava;
    }
  }

  _upravPolozku(BuildContext context) async {
    int? nakoupeneKusy = int.tryParse(widget.pocetKusuController.text);
    if (nakoupeneKusy == null) {
      return Zprava(text: 'Nakoupené kusy musí být celé číslo');
    } else {
      String stavPolozky = await polozkyController.upravPolozku(
          widget.zobrazovanaPolozka.id,
          widget.nazevController.text,
          nakoupeneKusy,
          double.tryParse(
              widget.nakupniCenaController.text.replaceAll(',', '.')),
          double.tryParse(
              widget.prodejniCenaController.text.replaceAll(',', '.')),
          _vratKategoriiDleNazvu(widget.kategorie),
          _vratUcetDleNazvu(widget.ucet),
          widget.poznamkaController.text);
      Zprava zprava = spravceZprav.nastavZpravu(stavPolozky);
      return zprava;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.zobrazovanaPolozka.id == 1000
            ? const Text(
                'Nová položka',
                style: TextStyle(fontSize: 30),
              )
            : Text(
                'Položka ID: ${widget.zobrazovanaPolozka.id}',
                style: const TextStyle(fontSize: 30),
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
            if (widget.zobrazovanaPolozka.id != 1000) {
              zprava = await _upravPolozku(context);
            } else {
              zprava = await _pridejPolozku(context);
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == 'Položka přidána' ||
                zprava.text == "Položka upravena") {
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
                    textController: widget.nazevController,
                    napoveda: 'Zadej název',
                    chybovka: 'Zadej název položky',
                    isRequired: true,
                  ),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.pocetKusuController,
                      napoveda: 'Počet nakoupených kusů',
                      chybovka: 'Zadej počet nakoupených kusů'),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.nakupniCenaController,
                      napoveda: 'Nákupní cena položky',
                      chybovka: 'Zadej nákupní cenu položky (1ks)'),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.prodejniCenaController,
                      napoveda: 'Prodejní cena položky',
                      chybovka: 'Zadej prodejní cenu položky (1ks)'),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: widget.kategorieController,
                      moznosti: nazvyKategorii,
                      napoveda: 'Vyber kategorii',
                      chybovka: 'Vyber kategorii položky',
                      onChanged: (String? value) {
                        widget.kategorie = value!;
                      }),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: widget.ucetController,
                      moznosti: nazvyUctu,
                      napoveda: 'Vyber účet',
                      chybovka: 'Vyber účet pro platbu',
                      onChanged: (String? value) {
                        widget.ucet = value!;
                      }),
                  const SizedBox(height: 25),
                  TextovePole(
                      textController: widget.poznamkaController,
                      napoveda: 'Zadej poznámku',
                      chybovka: 'Zadej poznámku',
                      isRequired: widget.zobrazovanaPolozka.id != 1000)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
