import 'package:flutter/material.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamBezSubtitle.dart';
import 'package:sikula/tridy/Konzument.dart';

// ignore: must_be_immutable
class SeznamStrelcu extends StatelessWidget {
  SeznamStrelcu({super.key});
  KonzumentController konzumentController = KonzumentController();

  Future<List<Konzument>> _vratSerazeneKonzumenty() async {
    List<Konzument> seznamKonzumentu =
        await konzumentController.vratSeznamKonzumentu();
    seznamKonzumentu.sort((a, b) {
      int aKusy = a.zkonzumovanychKusu ?? 0; // Pokud je null, použij 0
      int bKusy = b.zkonzumovanychKusu ?? 0; // Pokud je null, použij 0
      return bKusy.compareTo(aKusy); // Sestupné pořadí
    });
    int poradi = 1;
    for (int i = 0; i < seznamKonzumentu.length; i++) {
      if (i > 0 &&
          seznamKonzumentu[i].zkonzumovanychKusu ==
              seznamKonzumentu[i - 1].zkonzumovanychKusu) {
        seznamKonzumentu[i].poradi = seznamKonzumentu[i - 1].poradi;
      } else {
        seznamKonzumentu[i].poradi = poradi;
        poradi++;
      }
    }
    return seznamKonzumentu;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Střelci',
            style: TextStyle(fontFamily: 'Smokum', letterSpacing: 10)),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      body: Column(
        children: [
          Expanded(
            child: SeznamBezSubtitle(
                futureSeznam: _vratSerazeneKonzumenty(),
                titleFce: (Konzument konzument) => konzument.prezdivka,
                trailingFce: (Konzument konzument) =>
                    konzument.zkonzumovanychKusu.toString(),
                leadingFce: (Konzument konzument) =>
                    konzument.poradi.toString()),
          )
        ],
      ),
    );
  }
}
