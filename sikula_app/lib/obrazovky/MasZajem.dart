import 'package:flutter/material.dart';
import 'package:sikula/komponenty/Radek.dart';
import 'package:sikula/tridy/Disciplina.dart';

class MasZajem extends StatelessWidget {
  final Disciplina disciplina;
  const MasZajem({super.key, required this.disciplina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          disciplina.nazev,
          style: TextStyle(
              color:
                  disciplina.nazev == 'Ocásky' ? Colors.white : Colors.black),
        ),
        backgroundColor: disciplina.barva,
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radek(text: 'Teší mě tvůj zájem'),
            Radek(text: 'o tuto funkcionalitu.'),
            Radek(text: 'Zatím však nění dostupná,'),
            Radek(text: 'neboť vývoj aplikace'),
            Radek(text: 'je relativně náročný.'),
            Radek(text: 'Podpoř mě na mém herohero'),
            Radek(text: 'a za rok'),
            Radek(text: 'i toto bude fungovat. :-D '),
          ],
        ),
      ),
    );
  }
}
