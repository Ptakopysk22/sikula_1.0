import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/PokladnaController.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/FiltrovaciTlacitko.dart';
import 'package:sikula/komponenty/Seznamy/SeznamCestaFce.dart';
import 'package:sikula/tridy/ABCikony.dart';
import 'package:sikula/tridy/PokladniZaznam.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/VratkaObalu.dart';
import 'package:sikula/tridy/Zaloha.dart';

class Pokladna extends StatefulWidget {
  const Pokladna({super.key});

  @override
  State<Pokladna> createState() => _PokldnaState();
}

class _PokldnaState extends State<Pokladna> {
  PokladnaController pokladnaController = PokladnaController();
  bool zobrazeneVydaje = true;
  bool zobrazenePrijmy = true;
  bool zobrazeneNakupy = true;
  bool zobrazeneZalohy = true;
  bool zobrazenaKarta = true;
  bool zobrazenaHotovost = true;
  double soucet = 0;
  List<PokladniZaznam> seznamZaznamu = [];
  List<PokladniZaznam> filtrovaneZaznamy = [];
  KonzumentController konzumentController = KonzumentController();
  PolozkyController polozkyController = PolozkyController();

  @override
  void initState() {
    super.initState();

    _aplikujFiltry();
  }


  Future<List<PokladniZaznam>> _vratFiltrovaneZaznamy() async {
    List<PokladniZaznam> filtrovane =
        await pokladnaController.vratSeznamZaznamu();

    if (zobrazeneVydaje || zobrazenePrijmy) {
      filtrovane = filtrovane.where((zaznam) {
        if (zobrazeneVydaje && zaznam.castka! < 0) return true;
        if (zobrazenePrijmy && zaznam.castka! > 0) return true;
        return false;
      }).toList();
    } else {
      filtrovane = [];
    }

    if (zobrazeneNakupy || zobrazeneZalohy) {
      filtrovane = filtrovane.where((zaznam) {
        if (zobrazeneNakupy &&
            (zaznam.typTransakce.contains('Nákup') ||
                zaznam.typTransakce.contains('Vratka lahví') ||
                zaznam.typTransakce.contains('Vratka přepravek'))) return true;
        if (zobrazeneZalohy && zaznam.typTransakce.contains('zálohy')) {
          return true;
        }
        return false;
      }).toList();
    } else {
      filtrovane = [];
    }

    if (zobrazenaKarta || zobrazenaHotovost) {
      filtrovane = filtrovane.where((zaznam) {
        if (zobrazenaKarta && zaznam.ucet.contains('Karta')) return true;
        if (zobrazenaHotovost && zaznam.ucet.contains('Hotovost')) return true;
        return false;
      }).toList();
    } else {
      filtrovane = [];
    }
    return filtrovane;
  }

  _aplikujFiltry() async {
    final filtrovane = await _vratFiltrovaneZaznamy();
    setState(() {
      filtrovaneZaznamy = filtrovane;
      _nastavSoucet(filtrovaneZaznamy);
    });
  }

  _nastavSoucet(List<PokladniZaznam> seznamZaznamu) {
    double meziSoucet = 0;
    for (var zaznam in seznamZaznamu) {
      meziSoucet += zaznam.castka!;
    }
    soucet = meziSoucet;
  }

  _vratCestu(PokladniZaznam pokladniZaznam) {
    if (pokladniZaznam.typTransakce.contains('zálohy')) {
      return '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta/spravaKreditu';
    } else if (pokladniZaznam.typTransakce.contains('Nákup')) {
      return '/domovska/carkovnikDomovskaHospodar/seznamPolozek/detailPolozky';
    } else {
      return '/domovska/carkovnikDomovskaHospodar/seznamObalu/detailObalu';
    }
  }

  Future<Object?> _vratExtra(PokladniZaznam pokladniZaznam) async {
    if (pokladniZaznam.typTransakce.contains('zálohy')) {
      Zaloha zaloha = await konzumentController.vratZalohu(pokladniZaznam.id);
      return zaloha;
    } else if (pokladniZaznam.typTransakce.contains('Nákup')) {
      Polozka polozka = await polozkyController.vratPolozku(pokladniZaznam.id);
      return polozka;
    } else {
      VratkaObalu vratkaObalu =
          await polozkyController.vratVratkuObalu(pokladniZaznam.id);
      return vratkaObalu;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pokladna'),
          backgroundColor: Colors.brown[800],
          actions: [
            IconButton(
              onPressed: () => context.go(
                  '/domovska/carkovnikDomovskaHospodar/pokladna/pokladnaDetail'),
              icon: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 33,
              ),
            )
          ],
        ),
        backgroundColor: Colors.brown[300],
        body: Column(
          children: [
            const SizedBox(height: 3),
            Text('Součet: ${soucet.toStringAsFixed(2)}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FiltrovaciTlacitko(
                  text: 'Výdaje',
                  jeZmacknute: zobrazeneVydaje,
                  onPressed: () {
                    setState(() {
                      zobrazeneVydaje = !zobrazeneVydaje;
                    });
                    _aplikujFiltry();
                  },
                ),
                FiltrovaciTlacitko(
                  text: 'Příjmy',
                  jeZmacknute: zobrazenePrijmy,
                  onPressed: () {
                    setState(() {
                      zobrazenePrijmy = !zobrazenePrijmy;
                    });
                    _aplikujFiltry();
                  },
                )
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FiltrovaciTlacitko(
                  text: 'Nákupy',
                  jeZmacknute: zobrazeneNakupy,
                  onPressed: () {
                    setState(() {
                      zobrazeneNakupy = !zobrazeneNakupy;
                    });
                    _aplikujFiltry();
                  },
                ),
                FiltrovaciTlacitko(
                  text: 'Zálohy',
                  jeZmacknute: zobrazeneZalohy,
                  onPressed: () {
                    setState(() {
                      zobrazeneZalohy = !zobrazeneZalohy;
                    });
                    _aplikujFiltry();
                  },
                )
              ],
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FiltrovaciTlacitko(
                  text: 'Karta',
                  jeZmacknute: zobrazenaKarta,
                  onPressed: () {
                    setState(() {
                      zobrazenaKarta = !zobrazenaKarta;
                    });
                    _aplikujFiltry();
                  },
                ),
                FiltrovaciTlacitko(
                  text: 'Hotovost',
                  jeZmacknute: zobrazenaHotovost,
                  onPressed: () {
                    setState(() {
                      zobrazenaHotovost = !zobrazenaHotovost;
                    });
                    _aplikujFiltry();
                  },
                )
              ],
            ),
            Divider(thickness: 1, color: Colors.brown.shade800),
            Expanded(
              child: SeznamCestaFce<PokladniZaznam>(
                futureSeznam: _vratFiltrovaneZaznamy(),
                titleFce: (pokladniZaznam) => pokladniZaznam.nadpis,
                subtitleFce: (pokladniZaznam) =>
                    '${pokladniZaznam.typTransakce} - ${pokladniZaznam.ucet}',
                ikonaFce: (PokladniZaznam pokladniZaznam) {
                  String inicial = pokladniZaznam.vyridil[0].toUpperCase();
                  return Icon(ABCikony().mapaIkon[inicial]);
                },
                leadingFce: (pokladniZaznam) =>
                    '${pokladniZaznam.castka!.toStringAsFixed(0)},-',
                cestaFce: (pokladniZaznam) => _vratCestu(pokladniZaznam),
                extraFce: (pokladniZaznnam) => _vratExtra(pokladniZaznnam),
                onReturn: () {
                  _aplikujFiltry();
                  setState(() {});
                },
              ),
            )

          ],
        ));
  }
}




