import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamBezTrailing.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/TransakceKonzumenta.dart';

// ignore: must_be_immutable
class SeznamTransakciKonzumenta extends StatelessWidget {
  Konzument? zobrazovanyKonzument = AktualniVedouci.vedouci!.konzument;
  SeznamTransakciKonzumenta({super.key});

  KonzumentController konzumentController = KonzumentController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transakce'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      body: Column(
        children: [
          Expanded(
            child: SeznamBezTrailing<TransakceKonzumenta>(
              futureSeznam: konzumentController
                  .vratTransakceKonzumenta(zobrazovanyKonzument!),
              titleFce: (TransakceKonzumenta transakceKonzumace) =>
                  transakceKonzumace.nadpis,
              subtitleFce: (TransakceKonzumenta transakceKonzumace) {
                DateTime? datumAcas = transakceKonzumace.datumAcas;
                DateFormat formatter = DateFormat('d.M. HH:mm:ss');
                String formatovaneDC = formatter.format(datumAcas);
                List<String> casAzucastneni = [
                  formatovaneDC,
                  transakceKonzumace.vyridil
                ];
                return casAzucastneni;
              },
              leadingFce: (TransakceKonzumenta transakceKonzumace) =>'${transakceKonzumace.cena!.toStringAsFixed(0)},-',
              cesta:
                   '/domovska/carkovnikDomovskaKonzument/seznamTransakciKonzumenta/detailTransakceKonzumenta',
            ),
          ) 
        ],
      ),
    );
  }
}
