import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Tlacitko.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';

class CarkovnikDomovskaHospodar extends StatefulWidget {
  const CarkovnikDomovskaHospodar({super.key});

  @override
  State<CarkovnikDomovskaHospodar> createState() => _CarkovnikDomovskaHospodarState();
}

class _CarkovnikDomovskaHospodarState extends State<CarkovnikDomovskaHospodar> {
    Future<bool> _onWillPop() async {
    context.go('/domovska');
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hospodář',
                style: TextStyle(fontSize: 15),
              ),
              Text('${AktualniVedouci.vedouci?.prezdivka}')
            ],
          ),
          backgroundColor: Colors.brown[800],
          actions: [
            IconButton(
              onPressed: () => context.go('/domovska/carkovnikDomovskaKonzument'),
              icon: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 33,
              ),
            )
          ],
        ),
        backgroundColor: Colors.brown[300],
        body: Column(
          children: [
            const SizedBox(height: 25),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');}, text: 'Konzumenti'),
            const SizedBox(height: 20),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/seznamPolozek');}, text: 'Položky'),
            const SizedBox(height: 20),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/seznamKonzumaci');}, text: 'Konzumace'),
            const SizedBox(height: 20),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/pokladna');}, text: 'Pokladna'),
            const SizedBox(height: 20),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/sklipek');}, text: 'Sklípek'),
            const SizedBox(height: 20),
            Tlacitko(poZmacknuti: () {context.go('/domovska/carkovnikDomovskaHospodar/seznamObalu');}, text: 'Obaly'),
          ],
        ),
      ),
    );
  }
}
