import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/DatabazeController.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/CiselnePole.dart';
import 'package:sikula/komponenty/TextovePole.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/VratkaObalu.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class DetailObalu extends StatefulWidget {
  final VratkaObalu zobrazovanyObal;
  late final SingleValueDropDownController druhController;
  late final TextEditingController pocetKusuController;
  late final SingleValueDropDownController ucetController;
  late final TextEditingController poznamkaController;

  //zde nesmí být final!
  late String? druh = zobrazovanyObal.druh!.nazev;
  late String? ucet;

  DetailObalu({super.key, required this.zobrazovanyObal}) {
    DropDownValueModel? aktualniDruh = zobrazovanyObal.druh != null
        ? DropDownValueModel(
            name: druh!,
            value: druh!,
          )
        : null;
    druhController = SingleValueDropDownController(data: aktualniDruh);
    druh = aktualniDruh?.value as String?;
    pocetKusuController = TextEditingController(
        text: zobrazovanyObal.kusu == null
            ? ''
            : zobrazovanyObal.kusu.toString());
    poznamkaController = TextEditingController(text: zobrazovanyObal.poznamka);
    DropDownValueModel? aktualniUcet = zobrazovanyObal.ucet != null
        ? DropDownValueModel(
            name: zobrazovanyObal.ucet!.nazev,
            value: zobrazovanyObal.ucet!.nazev,
          )
        : null;
    ucetController = SingleValueDropDownController(data: aktualniUcet);
    ucet = aktualniUcet?.value;
  }

  @override
  State<DetailObalu> createState() => _DetailObaluState();
}

class _DetailObaluState extends State<DetailObalu> {
  late List<Ucet> seznamUctu;
  List<String> nazvyUctu = [];
  //List<String> nazvyDruhu = DruhObaluExtension2.names; změněno na tvrdu, Enum neumí ř!
  List<String> nazvyDruhu = ['Lahve', 'Přepravky'];
  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  PolozkyController polozkyController = PolozkyController();
  DatabazeController databazeController = DatabazeController();

  @override
  void initState() {
    super.initState();
    _nactiNazvyUctu();
  }

  Future<void> _nactiNazvyUctu() async {
    seznamUctu = await databazeController.vratUcty();
    for (var ucet in seznamUctu) {
      nazvyUctu.add(ucet.nazev);
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

  _pridejObal(BuildContext context) async {
    int? kusy = int.tryParse(widget.pocetKusuController.text);
    if (kusy == null) {
      return Zprava(text: 'Počet kusů musí být celé číslo');
    } else {
      String stavObalu = await polozkyController.pridejObal(widget.druh, kusy,
          _vratUcetDleNazvu(widget.ucet), widget.poznamkaController.text);
      Zprava zprava = spravceZprav.nastavZpravu(stavObalu);
      return zprava;
    }
  }

  _upravObal(BuildContext context) async {
    int? kusy = int.tryParse(widget.pocetKusuController.text);
    if (kusy == null) {
      return Zprava(text: 'Počet kusů musí být celé číslo');
    } else {
      String stavObalu = await polozkyController.upravObal(
          widget.zobrazovanyObal.id,
          widget.druh,
          kusy,
          _vratUcetDleNazvu(widget.ucet),
          widget.poznamkaController.text);
      Zprava zprava = spravceZprav.nastavZpravu(stavObalu);
      return zprava;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.zobrazovanyObal.id != 1000
            ? Text('Obal ID ${widget.zobrazovanyObal.id}')
            : const Text('Vratka obalů'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          Zprava zprava;
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            if (widget.zobrazovanyObal.id != 1000) {
              zprava = await _upravObal(context);
            } else {
              zprava = await _pridejObal(context);
            }
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == 'Obaly vráceny' ||
                zprava.text == "Vratka obalu upravena") {
              context.pop(true); //pokyn že se má spodní obrazovka refreshovat
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
                  VyberZMoznosti(
                      moznostiContoller: widget.druhController,
                      moznosti: nazvyDruhu,
                      napoveda: 'Vyber druh',
                      chybovka: 'Vyber druh obalu',
                      onChanged: (String? value) {
                        setState(() {
                          widget.druh = value!;
                        });
                      }),
                  const SizedBox(height: 25),
                  CiselnePole(
                      cisloContoller: widget.pocetKusuController,
                      napoveda: 'Zadej počet kusů',
                      chybovka: 'Zadej počet vrácených kusů'),
                  const SizedBox(height: 25),
                  VyberZMoznosti(
                      moznostiContoller: widget.ucetController,
                      moznosti: nazvyUctu,
                      napoveda: 'Vyber účet',
                      chybovka: 'Vyber účet pro platbu',
                      onChanged: (String? value) {
                        setState(() {
                          widget.ucet = value!;
                        });
                      }),
                  const SizedBox(height: 25),
                  TextovePole(
                      textController: widget.poznamkaController,
                      napoveda: 'Zadej poznámku',
                      chybovka: 'Zadej poznámku',
                      isRequired: widget.zobrazovanyObal.id != 1000),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
