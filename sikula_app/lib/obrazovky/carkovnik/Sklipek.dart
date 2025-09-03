import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/FiltrovaciTlacitko.dart';
import 'package:sikula/komponenty/Seznamy/Seznam.dart';
import 'package:sikula/tridy/Polozka.dart';

class Sklipek extends StatefulWidget {
  const Sklipek({Key? key}) : super(key: key);

  @override
  State<Sklipek> createState() => _SklipekState();
}

class _SklipekState extends State<Sklipek> {
  PolozkyController polozkyController = PolozkyController();
  bool zobrazVyprodane = false;
  List<Polozka> seznamPolozek = [];
  List<Polozka> filtrovanePolozky = [];

  @override
  void initState() {
    super.initState();
    _aplikujFiltry();
  }

  _aplikujFiltry() async {
    final filtrovane = await _vratFiltrovanePolozky();
    setState(() {
      filtrovanePolozky = filtrovane;
    });
  }

  Future<List<Polozka>> _vratFiltrovanePolozky() async {
    List<Polozka> filtrovane = await polozkyController.vratPolozkyVeSklipku();

    if (!zobrazVyprodane) {
      filtrovane = filtrovane.where((polozka) {
        return polozka.zbyvajiciKusy! > 0;
      }).toList();
    }

    return filtrovane;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sklípek'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/domovska/carkovnikDomovskaHospodar/sklipek/seznamKorekci');
        },
        child: const Icon(FontAwesomeIcons.k),
      ),
      body: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            FiltrovaciTlacitko(
              text: 'Včetně vyprodaných',
              jeZmacknute: zobrazVyprodane,
              onPressed: () {
                setState(() {
                  zobrazVyprodane = !zobrazVyprodane;
                });
                _aplikujFiltry();
              },
            )
          ]),
          Expanded(
            child: Seznam<Polozka>(
              futureSeznam: _vratFiltrovanePolozky(),
              titleFce: (polozka) => '${polozka.nazev}(${polozka.id})',
              subtitleFce: (polozka) => '',
              ikonaFce: (polozka) {
                Color barva;
                if (polozka.vNabidce!) {
                  barva = Colors.green;
                } else {
                  barva = Colors.orange;
                }
                return Icon(Icons.circle, color: barva);
              },
              leadingFce: (polozka) => polozka.zbyvajiciKusy.toString(),
              cesta: '/domovska/carkovnikDomovskaHospodar/sklipek/pridaniKorekce',
              onReturn: () {
                // Refresh data action
                _aplikujFiltry();
              },
            ),
          )
        ],
      ),
    );
  }
}

