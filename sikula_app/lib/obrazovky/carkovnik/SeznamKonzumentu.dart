/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Seznamy/SeznamSwipe.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

class SeznamKonzumentu extends StatefulWidget {
  const SeznamKonzumentu({super.key});

  @override
  State<SeznamKonzumentu> createState() => _SeznamKonzumentuState();
}

class _SeznamKonzumentuState extends State<SeznamKonzumentu> {
  KonzumentController konzumentController = KonzumentController();
  List<Konzument> seznamKonzumentu = [];

  Future<void> _refreshData() async {
    final updatedSeznamKonzument =
        await konzumentController.vratSeznamKonzumentu();
    setState(() {
      seznamKonzumentu = updatedSeznamKonzument;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konzumenti'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(
              '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu',
              extra: Vedouci(id: 1000, prezdivka: '', email: '', funkce: ''));
          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
              child: SeznamSwipe<Konzument>(
            futureSeznam: konzumentController.vratSeznamKonzumentu(),
            titleFce: (konzument) => konzument.vratPrezdivku(),
            subtitleFce: (konzument) => konzument.cip,
            trailingFce: (konzument) => konzument.kredit.toString(),
            cesta:
                '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/detailKonzumenta',
            cestaPravySwipe:
                '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta',
            cestaLevySwipe:
                '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/konzumaceKonzumenta',
            onReturn: _refreshData,
          ))
        ],
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/Seznamy/SeznamSwipe.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

class SeznamKonzumentu extends StatefulWidget {
  const SeznamKonzumentu({super.key});

  @override
  State<SeznamKonzumentu> createState() => _SeznamKonzumentuState();
}

class _SeznamKonzumentuState extends State<SeznamKonzumentu> {
  KonzumentController konzumentController = KonzumentController();
  List<Konzument> seznamKonzumentu = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final updatedSeznamKonzument =
        await konzumentController.vratSeznamKonzumentu();
    setState(() {
      seznamKonzumentu = updatedSeznamKonzument;
    });
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar');
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Konzumenti'),
          backgroundColor: Colors.brown[800],
        ),
        backgroundColor: Colors.brown[300],
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push(
                '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu',
                extra: Vedouci(id: 1000, prezdivka: '', email: '', funkce: ''));
            if (result == true) {
              _refreshData(); // Refresh data when returning to this screen
            }
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
          future: konzumentController.vratSeznamKonzumentu(),
          builder: (BuildContext context, AsyncSnapshot<List<Konzument>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Nacitac();
            } else if (snapshot.hasError) {
              return Center(child: Text('Chyba při načítání dat: ${snapshot.error}'));
            } else {
              seznamKonzumentu = snapshot.data ?? [];
              return Column(
                children: [
                  Expanded(
                    child: SeznamSwipe<Konzument>(
                      futureSeznam: Future.value(seznamKonzumentu),
                      titleFce: (konzument) => konzument.vratPrezdivku(),
                      subtitleFce: (konzument) => konzument.cip,
                      trailingFce: (konzument) => '${konzument.kredit} Kč',
                      cesta:
                          '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/detailKonzumenta',
                      cestaPravySwipe:
                          '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/zalohyKonzumenta',
                      cestaLevySwipe:
                          '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/konzumaceKonzumenta',
                      onReturn: _refreshData,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

