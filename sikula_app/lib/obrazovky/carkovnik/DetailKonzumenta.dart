/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

// ignore: must_be_immutable
class DetailKonzumenta extends StatefulWidget {
  Konzument zobrazovanyKonzument;

  DetailKonzumenta({super.key, required this.zobrazovanyKonzument});

  @override
  State<DetailKonzumenta> createState() => _DetailKonzumentaState();
}

class _DetailKonzumentaState extends State<DetailKonzumenta> {
  double padding1 = 50;
  double padding2 = 10;
  double padding3 = 5;
  double padding4 = 10;
  double velikostPisma1 = 22;
  double velikostPisma2 = 30;

  VedouciController vedouciController = VedouciController();
  KonzumentController konzumentController = KonzumentController();

  Future<Vedouci> _vratVedoucihoDleKonzumenta(Konzument konzument) async {
    Vedouci zobrazovanyVedouci =
        await vedouciController.vratVedoucihoDleKonzumenta(konzument);
    return zobrazovanyVedouci;
  }

  Future<void> _refreshKonzument() async {
    final updatedKonzument = await konzumentController
        .vratKonzumenta(widget.zobrazovanyKonzument.id);
    setState(() {
      widget.zobrazovanyKonzument = updatedKonzument;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Detail - ${widget.zobrazovanyKonzument.prezdivka}'),
          backgroundColor: Colors.brown[800],
        ),
        backgroundColor: Colors.brown[300],
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Číslo čipu:',
                style: TextStyle(
                    fontSize: velikostPisma1, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.zobrazovanyKonzument.cip}',
                      style: TextStyle(fontSize: velikostPisma1),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Vedouci vedouci = await _vratVedoucihoDleKonzumenta(
                            widget.zobrazovanyKonzument);
                        final result = context.push(
                            '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu',
                            extra: vedouci);
                        if (result == true) {
                          await _refreshKonzument();
                          setState(() {
                            konzumentController
                                .vratSeznamZaloh(widget.zobrazovanyKonzument);
                          });
                        }
                      },
                      child: Icon(
                        Icons.replay_circle_filled_outlined,
                        color: Colors.brown[800],
                        size: 40.0,
                      ),
                    )
                  ],
                ),
              ),
              Text(
                'Stav kreditu:',
                style: TextStyle(
                    fontSize: velikostPisma1, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                child: Text(
                  '${widget.zobrazovanyKonzument.kredit},-',
                  style: TextStyle(fontSize: velikostPisma2),
                ),
              ),
              Text(
                'Zkonzumovaných kusů:',
                style: TextStyle(
                    fontSize: velikostPisma1, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                child: Text(
                  '${widget.zobrazovanyKonzument.zkonzumovanychKusu} ks',
                  style: TextStyle(fontSize: velikostPisma2),
                ),
              ),
              Text(
                'Načárkovaných kusů:',
                style: TextStyle(
                    fontSize: velikostPisma1, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                child: Text(
                  '${widget.zobrazovanyKonzument.nacarkovanychKusu} ks',
                  style: TextStyle(fontSize: velikostPisma2),
                ),
              ),
            ],
          ),
        ));
  }
}*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

// ignore: must_be_immutable
class DetailKonzumenta extends StatefulWidget {
  Konzument zobrazovanyKonzument;

  DetailKonzumenta({super.key, required this.zobrazovanyKonzument});

  @override
  State<DetailKonzumenta> createState() => _DetailKonzumentaState();
}

class _DetailKonzumentaState extends State<DetailKonzumenta> {
  double padding1 = 50;
  double padding2 = 10;
  double padding3 = 5;
  double padding4 = 10;
  double velikostPisma1 = 22;
  double velikostPisma2 = 30;

  VedouciController vedouciController = VedouciController();
  KonzumentController konzumentController = KonzumentController();

  Future<Vedouci> _vratVedoucihoDleKonzumenta(Konzument konzument) async {
    Vedouci zobrazovanyVedouci =
        await vedouciController.vratVedoucihoDleKonzumenta(konzument);
    return zobrazovanyVedouci;
  }

  Future<Konzument> _refreshKonzument() async {
    final updatedKonzument = await konzumentController
        .vratKonzumenta(widget.zobrazovanyKonzument.id);
    return updatedKonzument;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, true);
          return false;
        },
      child: FutureBuilder<Konzument>(
        future: _refreshKonzument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Chyba při načítání dat: ${snapshot.error}'));
          } else {
            final konzument = snapshot.data!;
            return Scaffold(
              appBar: AppBar(
                title: Text('Detail - ${konzument.prezdivka}'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              body: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Číslo čipu:',
                      style: TextStyle(
                          fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${konzument.cip}',
                            style: TextStyle(fontSize: velikostPisma1),
                          ),
                          GestureDetector(
                            onTap: () async {
                              Vedouci vedouci = await _vratVedoucihoDleKonzumenta(konzument);
                              final result = await context.push(
                                '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu',
                                extra: vedouci,
                              );
                              if (result == true) {
                                setState(() {
                                  _refreshKonzument();
                                });
                              }
                            },
                            child: Icon(
                              Icons.replay_circle_filled_outlined,
                              color: Colors.brown[800],
                              size: 40.0,
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      'Stav kreditu:',
                      style: TextStyle(
                          fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                      child: Text(
                        '${konzument.kredit},-',
                        style: TextStyle(fontSize: velikostPisma2),
                      ),
                    ),
                    Text(
                      'Zkonzumovaných kusů:',
                      style: TextStyle(
                          fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                      child: Text(
                        '${konzument.zkonzumovanychKusu} ks',
                        style: TextStyle(fontSize: velikostPisma2),
                      ),
                    ),
                    Text(
                      'Načárkovaných kusů:',
                      style: TextStyle(
                          fontSize: velikostPisma1, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(padding1, padding2, padding3, padding4),
                      child: Text(
                        '${konzument.nacarkovanychKusu} ks',
                        style: TextStyle(fontSize: velikostPisma2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

