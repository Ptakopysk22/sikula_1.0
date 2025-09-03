import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sikula/tridy/Korekce.dart';

// ignore: must_be_immutable
class DetailKorekce extends StatelessWidget {
  Korekce zobrazovanaKorekce;
  double padding1 = 50;
  double padding2 = 10;
  double padding3 = 5;
  double padding4 = 10;
  double velikostPisma1 = 22;
  double velikostPisma2 = 30;
  DetailKorekce({super.key, required this.zobrazovanaKorekce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Korekce ID ${zobrazovanaKorekce.id}',
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
                      '${zobrazovanaKorekce.polozka.nazev} (${zobrazovanaKorekce.polozka.id})',
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Rozdíl:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      '${zobrazovanaKorekce.kusu} ks',
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
                          .format(zobrazovanaKorekce.datumAcas),
                      style: TextStyle(fontSize: velikostPisma2),
                    ),
                  ),
                  Text(
                    'Zapsal:',
                    style: TextStyle(
                        fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        padding1, padding2, padding3, padding4),
                    child: Text(
                      zobrazovanaKorekce.zapsal,
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
                      zobrazovanaKorekce.poznamka ?? '',
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
