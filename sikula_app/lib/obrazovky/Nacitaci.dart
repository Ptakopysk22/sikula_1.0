import 'package:flutter/material.dart';
import 'package:sikula/komponenty/LogoNazev.dart';

class Nacitaci extends StatefulWidget {
  const Nacitaci({super.key});

  @override
  State<Nacitaci> createState() => _NacitaciState();
}

class _NacitaciState extends State<Nacitaci> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LogoNazev(prihlasovaci: false),
    );
  }
}
