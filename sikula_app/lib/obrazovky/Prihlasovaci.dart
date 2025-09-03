import 'package:flutter/material.dart';
import 'package:sikula/komponenty/LogoNazev.dart';

class Prihlasovaci extends StatefulWidget {
  const Prihlasovaci({super.key});

  @override
  State<Prihlasovaci> createState() => _PrihlasovaciState();
}

class _PrihlasovaciState extends State<Prihlasovaci> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LogoNazev(prihlasovaci: true),
    );
  }
}
