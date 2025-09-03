import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/tridy/Konzumace.dart';

// ignore: must_be_immutable
class DetailKonzumaceHlavas extends StatelessWidget {
  final Konzumace zobrazovanaKonzumace;
  double padding1 = 50;
  double padding2 = 10;
  double padding3 = 5;
  double padding4 = 10;
  double velikostPisma1 = 22;
  double velikostPisma2 = 30;

  DetailKonzumaceHlavas({super.key, required this.zobrazovanaKonzumace});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Konzumace ID ${zobrazovanaKonzumace.id}',
            style: const TextStyle(fontSize: 32),
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
                      '${zobrazovanaKonzumace.polozka.nazev} (${zobrazovanaKonzumace.polozka.id})',
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
                      '${zobrazovanaKonzumace.cena},-',
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
                          .format(zobrazovanaKonzumace.datumAcas),
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Konzument:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaKonzumace.konzument!.prezdivka,
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Čárkoval:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaKonzumace.carkujici.prezdivka,
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
                      zobrazovanaKonzumace.poznamka ?? '',
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
