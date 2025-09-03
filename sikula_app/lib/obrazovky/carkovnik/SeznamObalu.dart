import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sikula/controllers/PolozkyController.dart';
import 'package:sikula/komponenty/Seznamy/Seznam.dart';
import 'package:sikula/tridy/ABCikony.dart';
import 'package:sikula/tridy/VratkaObalu.dart';

class SeznamObalu extends StatefulWidget {
  const SeznamObalu({super.key});

  @override
  State<SeznamObalu> createState() => _SeznamObaluState();
}

class _SeznamObaluState extends State<SeznamObalu> {
  PolozkyController polozkyController = PolozkyController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vrácené obaly'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(
            '/domovska/carkovnikDomovskaHospodar/seznamObalu/detailObalu',
            extra: VratkaObalu(
                id: 1000,
                datumAcas: null,
                kusu: null,
                druh: null,
                ucet: null,
                vyridil: null,
                poznamka: null),
          );
          if (result == true) {
            setState(() {
              polozkyController.vratVratkyObalu(); // Načítáme data znovu
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: Seznam<VratkaObalu>(
              futureSeznam: polozkyController.vratVratkyObalu(),
              titleFce: (vratkaObalu) => '${vratkaObalu.kusu}ks - ${vratkaObalu.druh!.nazev}',
              subtitleFce: (vratkaObalu) {
                DateFormat formatter = DateFormat('dd.MM. HH:mm:ss');
                String formatovaneDC = formatter.format(vratkaObalu.datumAcas!);
                return formatovaneDC;
              },
              ikonaFce: (vratkaObalu) {
                String inicial = vratkaObalu.vyridil![0].toUpperCase();
                return Icon(ABCikony().mapaIkon[inicial]);
              },
              leadingFce: (vratkaObalu) => vratkaObalu.id.toString(),
              cesta: '/domovska/carkovnikDomovskaHospodar/seznamObalu/detailObalu',
              onReturn: () {
                // Refresh data action
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}

