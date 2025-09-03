
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/PokladnaController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/BankovniUcet.dart';

// ignore: must_be_immutable
class PokladnaDetail extends StatefulWidget {
  const PokladnaDetail({super.key});

  @override
  State<PokladnaDetail> createState() => _PokladnaDetailState();
}

class _PokladnaDetailState extends State<PokladnaDetail> {
  final PokladnaController pokladnaController = PokladnaController();
  final VedouciController vedouciController = VedouciController();

  late String financniRezerva;
  BankovniUcet? bankovniUcet;

  Future<void> _vratData() async {
    try {
      financniRezerva = await pokladnaController.vratFinancniRezervu();
      bankovniUcet =
          await vedouciController.vratBankovniUcet(AktualniVedouci.vedouci);
    } catch (e) {
      print('Chyba při načítání dat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokladna'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _vratData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Nacitac();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Chyba při načítání dat: ${snapshot.error}'),
                    );
                  } else {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Finanční rezerva:',
                            style: TextStyle(fontSize: 25),
                          ),
                          Text(
                            '$financniRezerva Kč',
                            style: const TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Hospodářův účet:',
                            style: TextStyle(fontSize: 25),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final result = await context.push(
                                '/domovska/carkovnikDomovskaHospodar/pokladna/pokladnaDetail/nastaveniUctu',
                                extra: bankovniUcet ??
                                    BankovniUcet(
                                        zakladniCast: '', kodBanky: ''),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                border: Border.all(width: 2.5),
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.brown[400],
                              ),
                              child: Text(
                                bankovniUcet != null
                                    ? bankovniUcet!.toString()
                                    : 'Zadej',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: () {
                              context.go(
                                  '/domovska/carkovnikDomovskaHospodar/pokladna/pokladnaDetail/presunMeziUcty');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Převod mezi účty',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
