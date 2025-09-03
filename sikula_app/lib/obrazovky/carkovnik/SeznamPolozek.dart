import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/Seznamy/Seznam.dart';
import 'package:sikula/tridy/ABCikony.dart';
import 'package:sikula/tridy/Polozka.dart';

class SeznamPolozek extends StatefulWidget {
  const SeznamPolozek({super.key});

  @override
  State<SeznamPolozek> createState() => _SeznamPolozekState();
}

class _SeznamPolozekState extends State<SeznamPolozek> {
  PolozkyController polozkyController = PolozkyController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Položky'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(
              '/domovska/carkovnikDomovskaHospodar/seznamPolozek/detailPolozky',
              extra: Polozka(
                  id: 1000,
                  datumAcas: null,
                  nazev: null,
                  nakoupeneKusy: null,
                  zbyvajiciKusy: null,
                  nakupniCena: null,
                  prodejniCena: null,
                  kategorie: null,
                  nakoupil: null,
                  poznamka: null));
          if (result == true) {
            setState(() {
              polozkyController.vratSeznamPolozek(); // Načítáme data znovu
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: Seznam<Polozka>(
              futureSeznam: polozkyController.vratSeznamPolozek(),
              titleFce: (polozka) => polozka.nazev,
              subtitleFce: (polozka) {
                DateFormat formatter = DateFormat('dd.MM. HH:mm:ss');
                String formatovaneDC = formatter.format(polozka.datumAcas!);
                return formatovaneDC;
              },
              ikonaFce: (polozka) {
                String inicial = polozka.nakoupil![0].toUpperCase();
                return Icon(ABCikony().mapaIkon[inicial]);
              },
              leadingFce: (polozka) => polozka.id.toString(),
              cesta:
                  '/domovska/carkovnikDomovskaHospodar/seznamPolozek/detailPolozky',
              onReturn: () {
                // Refresh data action
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }
}





