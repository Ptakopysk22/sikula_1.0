import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/Seznamy/Seznam.dart';
import 'package:sikula/tridy/ABCikony.dart';
import 'package:sikula/tridy/Korekce.dart';

class SeznamKorekci extends StatefulWidget {
  const SeznamKorekci({super.key});

  @override
  State<SeznamKorekci> createState() => _SeznamKorekciState();
}

class _SeznamKorekciState extends State<SeznamKorekci> {
  PolozkyController polozkyController = PolozkyController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Korekce'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      body: Column(
        children: [
          Expanded(
              child: Seznam<Korekce>(
              futureSeznam: polozkyController.vratKorekce(),
              titleFce: (korekce) => '${korekce.polozka.nazev}(${korekce.polozka.id})',
              subtitleFce: (korekce) {
                DateFormat formatter = DateFormat('dd.MM. HH:mm:ss');
                String formatovaneDC = formatter.format(korekce.datumAcas);
                return formatovaneDC;
              },
              ikonaFce: (korekce) {
                String inicial = korekce.zapsal[0].toUpperCase();
                return Icon(ABCikony().mapaIkon[inicial]);
              },
              leadingFce: (korekce) => korekce.kusu.toString(),
              cesta: '/domovska/carkovnikDomovskaHospodar/sklipek/seznamKorekci/detailKorekce',
              onReturn: () {
                // Refresh data action
                setState(() {});
              },
            ),)
        ],
      ),
    );
  }
}
