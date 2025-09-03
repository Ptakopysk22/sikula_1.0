import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/tridy/TransakceKonzumenta.dart';

// ignore: must_be_immutable
class DetailTransakceKonzumenta extends StatelessWidget {
  final TransakceKonzumenta zobrazovanaTransakceKonzumenta;
  double padding1 = 50;
  double padding2 = 10;
  double padding3 = 5;
  double padding4 = 10;
  double velikostPisma1 = 22;
  double velikostPisma2 = 30;

  DetailTransakceKonzumenta(
      {super.key, required this.zobrazovanaTransakceKonzumenta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Transakce ID ${zobrazovanaTransakceKonzumenta.id}',
          ),
          backgroundColor: Colors.brown[800],
        ),
        backgroundColor: Colors.brown[300],
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Položka:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaTransakceKonzumenta.nadpis,
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Celková cena:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      '${zobrazovanaTransakceKonzumenta.cena},-',
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Datum a čas vyřízení:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      DateFormat('d.M. HH:mm:ss')
                          .format(zobrazovanaTransakceKonzumenta.datumAcas),
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Vyřídil:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaTransakceKonzumenta.vyridil,
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Poznámka:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaTransakceKonzumenta.poznamka ?? '',
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
