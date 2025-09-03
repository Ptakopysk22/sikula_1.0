import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamBezTrailing.dart';
import 'package:sikula/tridy/Konzumace.dart';

// ignore: must_be_immutable
class SeznamKonzumaciHlavas extends StatelessWidget {
  SeznamKonzumaciHlavas({super.key});
  KonzumentController konzumentController = KonzumentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konzumace'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      body: Column(
        children: [
          Expanded(
            child: SeznamBezTrailing<Konzumace>(
              futureSeznam: konzumentController.vratVsechnyKonzumace(),
              titleFce: (konzumace) =>
                  '${konzumace.kusu}ks ${konzumace.polozka.nazev} (${konzumace.polozka.id})',
              subtitleFce: (konzumace) {
                DateTime? datumAcas = konzumace.datumAcas;
                DateFormat formatter = DateFormat('d.M. HH:mm:ss');
                String formatovaneDC = formatter.format(datumAcas);
                List<String> casAzucastneni = [
                  formatovaneDC,
                  konzumace.konzument!.prezdivka,
                  konzumace.carkujici.prezdivka
                ];
                return casAzucastneni;
              },
              leadingFce: (konzumace) => konzumace.cena!.toStringAsFixed(1),
              cesta: '/domovska/carkovnikDomovskaKonzument/seznamKonzumaciHlavas/detailKonzumaceHlavas',
            ),
          )
        ],
      ),
    );
  }
}
