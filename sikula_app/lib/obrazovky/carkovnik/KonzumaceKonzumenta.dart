import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamBezTrailing.dart';
import 'package:sikula/tridy/Konzumace.dart';
import 'package:sikula/tridy/Konzument.dart';

// ignore: must_be_immutable
class KonzumaceKonzumenta extends StatefulWidget {
  Konzument zobrazovanyKonzument;
  KonzumaceKonzumenta({super.key, required this.zobrazovanyKonzument});

  @override
  State<KonzumaceKonzumenta> createState() => _KonzumaceKonzumaciState();
}

class _KonzumaceKonzumaciState extends State<KonzumaceKonzumenta> {
  KonzumentController konzumentController = KonzumentController();

  Future<void> _refreshKonzument() async {
    final updatedKonzument = await konzumentController
        .vratKonzumenta(widget.zobrazovanyKonzument.id);
    setState(() {
      widget.zobrazovanyKonzument = updatedKonzument;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Konzumace',
                  style: TextStyle(fontSize: 15),
                ),
                Text(widget.zobrazovanyKonzument.prezdivka)
              ],
            ),
            backgroundColor: Colors.brown[800],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await context.push(
                  '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/konzumaceKonzumenta/manualniCarkovani',
                  extra: widget.zobrazovanyKonzument);
              if (result == true) {
                setState(() {
                  konzumentController
                      .vratKonzumaceKonzumenta(widget.zobrazovanyKonzument);
                });
              }
            },
            child: const Icon(Icons.add),
          ),
          backgroundColor: Colors.brown[300],
          body: Column(
            children: [
              Expanded(
                child: SeznamBezTrailing<Konzumace>(
                  futureSeznam: konzumentController
                      .vratKonzumaceKonzumenta(widget.zobrazovanyKonzument),
                  titleFce: (konzumace) =>
                      '${konzumace.kusu}ks ${konzumace.polozka.nazev} (${konzumace.polozka.id})',
                  subtitleFce: (konzumace) {
                    DateTime? datumAcas = konzumace.datumAcas;
                    DateFormat formatter = DateFormat('d.M. HH:mm:ss');
                    String formatovaneDC = formatter.format(datumAcas);
                    List<String> casAzucastneni = [
                      formatovaneDC,
                      konzumace.carkujici.prezdivka
                    ];
                    return casAzucastneni;
                  },
                   leadingFce: (konzumace) => '${konzumace.cena!.toStringAsFixed(0)},-',
                  cesta:
                      '/domovska/carkovnikDomovskaHospodar/seznamKonzumaci/detailKonzumace',
                  onReturn: () async {
                    await _refreshKonzument();
                    setState(() {});
                  },
                ),
              ) 
            ],
          ),
        ));
  }
}
