import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamNabidka.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Zprava.dart';

class CipoveCarkovani extends StatefulWidget {
  final Konzument konzument;
  const CipoveCarkovani({super.key, required this.konzument});

  @override
  State<CipoveCarkovani> createState() => _CipoveCarkovaniState();
}

class _CipoveCarkovaniState extends State<CipoveCarkovani> {
  PolozkyController polozkyController = PolozkyController();
  double cenaVybranychPolozek = 0.0;
  int pocetVybranychPolozek = 0;
  List<Polozka> seznamPolozek = [];
  final AudioPlayer audioPlayer = AudioPlayer();
  VedouciController vedouciController = VedouciController();

  @override
  void initState() {
    super.initState();
    _loadPolozky();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPolozky();
  }

  void _loadPolozky() async {
    _prehrajZvuk('Protočení bubínku');
    await polozkyController.vratNabidkuPolozek().then((value) {
      setState(() {
        seznamPolozek = value;
        pocetVybranychPolozek = 0;
        cenaVybranychPolozek = 0.0;
      });
    });
  }

  _nacarkujPolozky() async {
    String stavCarkovani = '';
    Zprava? zprava;
    List<Polozka> nenulovePolozky = seznamPolozek
        .where((polozka) => (polozka.vybraneKusy ?? 0) > 0)
        .toList();
    if (nenulovePolozky.isEmpty) {
      zprava = Zprava(text: 'Vyber položku');
    } else {
      await _prehrajZvuk('Výstřel');
      for (var polozka in nenulovePolozky) {
        stavCarkovani = await polozkyController.nacarkujuPolozku(
            widget.konzument,
            AktualniVedouci.vedouci!.konzument,
            polozka,
            polozka.vybraneKusy);
      }
      if (stavCarkovani == 'polozka nacarkovana') {
        zprava = Zprava(text: 'Zásah');
      } else {
        zprava = Zprava(text: 'Chyba');
      }

      setState(() {
        // Resetování seznamu položek a dalších proměnných
        seznamPolozek.forEach((polozka) {
          polozka.vybraneKusy = 0;
        });
        pocetVybranychPolozek = 0;
        cenaVybranychPolozek = 0.0;
      });
    }
    return zprava;
  }

  void _predbezneNacarkujPolozku(Polozka polozka) {
    if (polozka.vybraneKusy == polozka.zbyvajiciKusy) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Maximální počet')));
    } else {
      _prehrajZvuk('Nabíjení');
      setState(() {
        polozka.vybraneKusy = (polozka.vybraneKusy ?? 0) + 1;
        pocetVybranychPolozek++;
        cenaVybranychPolozek += polozka.prodejniCena!;
      });
    }
  }

  Future<void> _prehrajZvuk(String druh) async {
    if (druh == 'Nabíjení') {
      await audioPlayer.play(AssetSource('sounds/shotgun_reload.mp3'));
    } else if (druh == 'Výstřel') {
      await audioPlayer.play(AssetSource('sounds/shotgun_firing.mp3'));
    } else if (druh == 'Protočení bubínku') {
      await audioPlayer.play(AssetSource('sounds/revolver_chamber_spin.mp3'));
    }
    // Získat délku zvuku a počkat, než se zvuk přehraje celý
    final duration = await audioPlayer.getDuration();
    await Future.delayed(duration ?? Duration(milliseconds: 10));
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    context.go('/domovska/carkovnikDomovskaKonzument');
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Čárkování',
              style: TextStyle(fontFamily: 'Smokum', fontSize: 40)),
          backgroundColor: Colors.brown[800],
        ),
        backgroundColor: Colors.brown[300],
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            Zprava zprava = await _nacarkujPolozky();
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(zprava.text)));
            if (zprava.text == 'Zásah') {
              Navigator.pop(context, true);
            }
          },
          child: Image.asset(
            'assets/zamerovac_ikona.png',
            width: 45,
            height: 45,
          ),
        ),
        body: Column(
          children: [
            Text('Dobíječ: ${AktualniVedouci.vedouci!.konzument!.prezdivka}',
                style: const TextStyle(fontFamily: 'Smokum', fontSize: 28)),
            Text(
                'Střelec: ${widget.konzument.prezdivka} (\$${widget.konzument.kredit})',
                style: const TextStyle(fontFamily: 'Smokum', fontSize: 28)),
            Text(
                'Načárkováno: $pocetVybranychPolozek ks ~ \$ $cenaVybranychPolozek',
                style: const TextStyle(fontFamily: 'Smokum', fontSize: 28)),
            Divider(thickness: 1, color: Colors.brown.shade800),
            Expanded(
              child: seznamPolozek.isEmpty
                  ? const Column(
                      children: [
                        Text('Dnes bude',
                            style:
                                TextStyle(fontFamily: 'Smokum', fontSize: 40)),
                        Text('ŽÍZEŇ',
                            style:
                                TextStyle(fontFamily: 'Smokum', fontSize: 50))
                      ],
                    )
                  : SeznamNabidka<Polozka>(
                      seznam: seznamPolozek,
                      titleFce: (Polozka polozka) => polozka.nazev,
                      trailingFce: (Polozka polozka) =>
                          '\$${polozka.prodejniCena}',
                      leadingFce: (Polozka polozka) =>
                          '${polozka.vybraneKusy ?? 0} ks',
                      onTap: _predbezneNacarkujPolozku,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
