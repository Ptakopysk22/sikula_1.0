import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Seznamy/Seznam.dart';
import 'package:sikula/tridy/Vedouci.dart';

class SeznamVedoucich extends StatefulWidget {
  const SeznamVedoucich({super.key});

  @override
  State<SeznamVedoucich> createState() => _VedouciState();
}

class _VedouciState extends State<SeznamVedoucich> {
  VedouciController vedouciController = VedouciController();

  _vratIkonu(Vedouci vedouci) {
    if (vedouci.funkce == 'U oddílu') {
      return const Icon(FontAwesomeIcons.childReaching);
    } else if (vedouci.funkce == 'Hlavas') {
      return const Icon(FontAwesomeIcons.crown);
    } else if (vedouci.funkce == 'Hospodář') {
      return const Icon(FontAwesomeIcons.sackDollar);
    } else {
      return const Icon(FontAwesomeIcons.poo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Vedoucí'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push(
                '/domovska/seznamVedoucich/detailVedouciho',
                extra:
                    Vedouci(id: 1000, prezdivka: '', email: '', funkce: null));
            if (result == true) {
              setState(() {
                vedouciController.vratSeznamVedoucich();
              });
            }
          },
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            Expanded(
              child: Seznam<Vedouci>(
                futureSeznam: vedouciController.vratSeznamVedoucich(),
                titleFce: (vedouci) => vedouci.vratPrezdivku(),
                subtitleFce: (vedouci) => vedouci.vratEmail(),
                ikonaFce: (veoduci) => _vratIkonu(veoduci),
                leadingFce: (vedouci) => vedouci.id.toString(),
                cesta: '/domovska/seznamVedoucich/detailVedouciho',
                onReturn: () {
                  setState(() {});
                },
              ),
            )
          ],
        ));
  }
}
