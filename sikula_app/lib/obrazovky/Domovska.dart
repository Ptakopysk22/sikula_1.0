import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/DomovskeIkony.dart';
import 'package:sikula/komponenty/Ikona.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/Radek.dart';
import 'package:sikula/tridy/Disciplina.dart';
import 'package:sikula/tridy/Vedouci.dart';

// ignore: must_be_immutable
class Domovska extends StatelessWidget {
  Domovska({super.key});
  //zde nesmí být final, jinak se nelze odhlásit
  VedouciController vedouciController = VedouciController();
  //final User firebaseUzivatel = FirebaseAuth.instance.currentUser!;

  void odhlasUzivatele(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    GoogleSignIn().signOut();
    context.go('/prihlasovaci');
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUzivatel = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<Vedouci>(
      future: vedouciController.vratVedouciho(firebaseUzivatel),
      builder: (BuildContext context, AsyncSnapshot<Vedouci> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Nacitac();
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Chyba při načítání dat: ${snapshot.error}'),
          );
        } else {
          Vedouci aktualniVedouci = snapshot.data ??
              Vedouci(
                  id: 1000,
                  prezdivka: 'Žádná',
                  email: 'Žádný',
                  funkce: 'Žádná');
          return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    onPressed: () => odhlasUzivatele(context),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.grey,
                    ),
                  )
                ],
                title: Text(aktualniVedouci.prezdivka),
                automaticallyImplyLeading: false,
                leading: aktualniVedouci.funkce != 'Žádná'
                    ? Builder(builder: (context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 33,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      })
                    : Container(),
              ),
              drawer: Drawer(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.app_shortcut_outlined),
                      title: Text('O aplikaci',
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () {
                        context.go('/domovska/oAplikaci');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.create_outlined),
                      title: Text('Zpětná vazba',
                          style: Theme.of(context).textTheme.bodyMedium),
                      onTap: () {
                        context.go('/domovska/zpetnaVazba');
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: aktualniVedouci.funkce == 'Hlavas'
                  ? FloatingActionButton(
                      onPressed: () {
                        context.go('/domovska/seznamVedoucich');
                      },
                      child: const Icon(Icons.person),
                    )
                  : null,
              body: aktualniVedouci.funkce == 'Žádná'
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radek(text: 'Nejsi přihlášen na táboře'),
                        Radek(text: 'Dojdi si za hlavasem.'),
                      ],
                    )
                  : Column(
                      children: [
                        const SizedBox(height: 25),
                        SizedBox(height: 250, child: DomovskeIkony()),
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 20),
                        SizedBox(
                            height: 125,
                            width: 500,
                            child: GridView.count(
                              crossAxisCount: 3,
                              children: [
                                Ikona(
                                  popisek: 'Ocásky',
                                  ikona: FontAwesomeIcons.yinYang,
                                  proklik: '/domovska/masZajem',
                                  barva: Colors.black,
                                  extra: Disciplina(
                                      nazev: 'Ocásky', barva: Colors.black),
                                ),
                                Ikona(
                                  popisek: 'Án',
                                  ikona: FontAwesomeIcons.ship,
                                  proklik: '/domovska/masZajem',
                                  barva: Colors.blue,
                                  extra: Disciplina(
                                      nazev: 'Án', barva: Colors.blue),
                                ),
                              ],
                            )),
                        const Divider(thickness: 1, color: Colors.grey),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Ikona(
                                popisek: 'Čárkovník',
                                ikona: FontAwesomeIcons.beerMugEmpty,
                                proklik: aktualniVedouci.funkce == 'Hospodář'
                                    ? '/domovska/carkovnikDomovskaHospodar'
                                    : '/domovska/carkovnikDomovskaKonzument',
                                barva: Colors.brown, extra: null,)
                          ],
                        )
                      ],
                    ));
        }
      },
    );
  }
}
