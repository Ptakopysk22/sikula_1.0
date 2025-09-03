import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Konzumace.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class DetailKonzumace extends StatefulWidget {
  final Konzumace zobrazovanaKonzumace;
  late final SingleValueDropDownController polozkaController;
  late final SingleValueDropDownController konzumentController;
  late final SingleValueDropDownController carkujiciController;
  late final TextEditingController cenaController;
  late final TextEditingController kusyController;
  late final TextEditingController poznamkaController;
  //zde nesmí být final!
  late String? polozka;
  late String? konzument;
  late String? carkujici;

  DetailKonzumace({super.key, required this.zobrazovanaKonzumace}) {
    DropDownValueModel? aktualniPolozka =
        zobrazovanaKonzumace.polozka.nazev != null
            ? DropDownValueModel(
                name:
                    '${zobrazovanaKonzumace.polozka.nazev!}(${zobrazovanaKonzumace.polozka.id})',
                value:
                    '${zobrazovanaKonzumace.polozka.nazev!}(${zobrazovanaKonzumace.polozka.id})',
              )
            : null;
    polozkaController = SingleValueDropDownController(data: aktualniPolozka);
    polozka = aktualniPolozka?.value;
    DropDownValueModel? aktualniKonzument =
        // ignore: unnecessary_null_comparison
        zobrazovanaKonzumace.konzument!.prezdivka != null
            ? DropDownValueModel(
                name: zobrazovanaKonzumace.konzument!.prezdivka,
                value: zobrazovanaKonzumace.konzument!.prezdivka,
              )
            : null;
    konzumentController =
        SingleValueDropDownController(data: aktualniKonzument);
    konzument = aktualniKonzument?.value;
    DropDownValueModel? aktualniCarkujici =
        // ignore: unnecessary_null_comparison
        zobrazovanaKonzumace.carkujici.prezdivka != null
            ? DropDownValueModel(
                name: zobrazovanaKonzumace.carkujici.prezdivka,
                value: zobrazovanaKonzumace.carkujici.prezdivka,
              )
            : null;
    carkujiciController =
        SingleValueDropDownController(data: aktualniCarkujici);
    carkujici = aktualniCarkujici?.value;
    cenaController =
        TextEditingController(text: zobrazovanaKonzumace.cena.toString());
    kusyController =
        TextEditingController(text: zobrazovanaKonzumace.kusu.toString());
    poznamkaController =
        TextEditingController(text: zobrazovanaKonzumace.poznamka);
  }

  @override
  State<DetailKonzumace> createState() => _DetailKonzumaceState();
}

class _DetailKonzumaceState extends State<DetailKonzumace> {
  late List seznamPolozek;
  late List seznamKonzumentu;
  List<String> nazvyPolozek = [];
  List<String> prezdivky = [];
  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  PolozkyController polozkyController = PolozkyController();
  KonzumentController konzumentController = KonzumentController();

  @override
  void initState() {
    super.initState();
    _nactiNazvyPolozek();
    _nactiJmenaPrezdivek();
  }

  Future<void> _nactiNazvyPolozek() async {
    seznamPolozek = await polozkyController.vratSeznamPolozek();
    for (var polozka in seznamPolozek) {
      nazvyPolozek.add('${polozka.nazev}(${polozka.id})');
    }
    setState(() {});
  }

  Future<void> _nactiJmenaPrezdivek() async {
    seznamKonzumentu = await konzumentController.vratSeznamKonzumentu();
    for (var konzument in seznamKonzumentu) {
      prezdivky.add(konzument.prezdivka);
    }
    setState(() {});
  }

  Polozka? _vratPolozkuDleNazvu(String? nazevPolozky) {
    List<String> parts = nazevPolozky!.split(RegExp(r'[\(\)]'));
    //String nazev = parts[0].trim();
    int id = int.parse(parts[1].trim());
    for (var polozka in seznamPolozek) {
      if (polozka.id == id) {
        return polozka;
      }
    }
    return null;
  }

  Konzument? _vratKonzumentaDlePrezdivku(String? prezdivka) {
    for (var konzument in seznamKonzumentu) {
      if (konzument.prezdivka == prezdivka) {
        return konzument;
      }
    }
    return null;
  }

  _upravKonzumaci(BuildContext context) async {
    int? kusy = int.tryParse(widget.kusyController.text);
    if (kusy == null) {
      return Zprava(text: 'Kusů musí být celé číslo');
    } else {
      String stavKonzumace = await polozkyController.upravKonzumaci(
          widget.zobrazovanaKonzumace.id,
          _vratPolozkuDleNazvu(widget.polozka),
          _vratKonzumentaDlePrezdivku(widget.konzument),
          _vratKonzumentaDlePrezdivku(widget.carkujici),
          double.tryParse(widget.cenaController.text.replaceAll(',', '.')),
          kusy,
          widget.poznamkaController.text);
      Zprava zprava = spravceZprav.nastavZpravu(stavKonzumace);
      return zprava;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Konzumace ID ${widget.zobrazovanaKonzumace.id}',
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
            zprava = await _upravKonzumaci(context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == "Konzumace upravena") {
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
                  VyberZMoznosti(
                      moznostiContoller: widget.polozkaController,
                      moznosti: nazvyPolozek,
                      napoveda: 'Vyber položku',
                      chybovka: 'Vyber položku',
                      onChanged: (String? value) {
                        widget.polozka = value!;
                      }),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: widget.konzumentController,
                      moznosti: prezdivky,
                      napoveda: 'Vyber přezdívku konzumenta',
                      chybovka: 'Vyber přezdívku konzumenta',
                      onChanged: (String? value) {
                        widget.konzument = value!;
                      }),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: widget.carkujiciController,
                      moznosti: prezdivky,
                      napoveda: 'Vyber přezdívku čárkujícícho',
                      chybovka: 'Vyber přezdívku čárkujícícho',
                      onChanged: (String? value) {
                        widget.carkujici = value!;
                      }),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.cenaController,
                      napoveda: 'Zadej pevnou cenu konzumace',
                      chybovka: 'Zadej pevnou cenu konzumace'),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.kusyController,
                      napoveda: 'Zadej počet kusů',
                      chybovka: 'Zadej počet kusů'),
                  const SizedBox(height: 25),
                  TextovePole(
                      textController: widget.poznamkaController,
                      napoveda: 'Zadej poznámku',
                      chybovka: 'Zadej poznámku',
                      isRequired: widget.zobrazovanaKonzumace.id != 1000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
