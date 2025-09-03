import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamBezLeading.dart';
import 'package:sikula/tridy/ABCikony.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Zaloha.dart';

// ignore: must_be_immutable
class ZalohyKonzumenta extends StatefulWidget {
  Konzument zobrazovanyKonzument;

  ZalohyKonzumenta({super.key, required this.zobrazovanyKonzument});

  @override
  State<ZalohyKonzumenta> createState() => _ZalohyKonzumentaState();
}

class _ZalohyKonzumentaState extends State<ZalohyKonzumenta> {
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
          //await _refreshKonzument();
          Navigator.pop(context, true);
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Zálohy',
                  style: TextStyle(fontSize: 15),
                ),
                Text(widget.zobrazovanyKonzument.prezdivka)
              ],
            ),
            backgroundColor: Colors.brown[800],
          ),
          backgroundColor: Colors.brown[300],
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await context.push(
                  '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta/spravaKreditu',
                  extra: Zaloha(
                      id: 1000,
                      konzument: widget.zobrazovanyKonzument,
                      datumAcas: null,
                      castka: null,
                      ucet: null,
                      vyridil: null,
                      poznamka: null));
              if (result == true) {
                await _refreshKonzument();
                setState(() {
                  konzumentController
                      .vratSeznamZaloh(widget.zobrazovanyKonzument);
                });
              }
            },
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              Expanded(
                child: SeznamBezLeading(
                  futureSeznam: konzumentController
                      .vratSeznamZaloh(widget.zobrazovanyKonzument),
                  titleFce: (zaloha) =>
                      '${zaloha.ucet!.nazev}: ${zaloha.castka!.toStringAsFixed(1)},-',
                  subtitleFce: (zaloha) {
                    DateFormat formatter = DateFormat('dd.MM. HH:mm:ss');
                    String formatovaneDC = formatter.format(zaloha.datumAcas!);
                    return formatovaneDC;
                  },
                  ikonaFce: (zaloha) {
                    String inicial = zaloha.vyridil![0].toUpperCase();
                    return Icon(ABCikony().mapaIkon[inicial]);
                  },
                  cesta:
                      '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta/spravaKreditu',
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
