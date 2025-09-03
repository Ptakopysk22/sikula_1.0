import 'package:flutter/material.dart';
import 'package:sikula/komponenty/Radek.dart';

class PresunMeziUcty extends StatelessWidget {
  const PresunMeziUcty({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Přesun mezi účty'),
          backgroundColor: Colors.brown[800],
        ),
        backgroundColor: Colors.brown[300],
        body: const Center(
            child: Column(
          children: [
            Radek(text: 'Cha, to sis myslel,'),
            Radek(text: 'že tu bude tato'),
            Radek(text: 'funkcionalita?'),
            Radek(text: 'To ses splet!'),
            Radek(text: 'Musíš provést vklad kreditu'),
            Radek(text: 'libovolnému konzumentovi'),
            Radek(text: '(třeba sobě) na účet (k/h)'),
            Radek(text: ',ze kterého vybíráš'),
            Radek(text: 'a následně provést'),
            Radek(text: 'opačnou transakci'),
            Radek(text: 's druhým typem účtu.'),
          ],
        )));
  }
}
