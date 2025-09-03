import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sikula/komponenty/Ikona.dart';
import 'package:sikula/tridy/Disciplina.dart';

class DomovskeIkony extends StatelessWidget {
  DomovskeIkony({super.key});

  final Map<String, Disciplina> discipliny = {
    'Stezka': Disciplina(nazev: 'Stezka', barva: Colors.yellow),
    'Shyby': Disciplina(nazev: 'Shyby', barva: Colors.purple),
    'Granáty': Disciplina(nazev: 'Granáty', barva: Colors.grey),
    'Lano': Disciplina(nazev: 'Lano', barva: Colors.green),
    'Úklid': Disciplina(nazev: 'Úklid', barva: Colors.white)
  };

  late final List<Ikona> ikony = [
    Ikona(
        popisek: discipliny['Stezka']!.nazev,
        ikona: FontAwesomeIcons.personRunning,
        proklik: '/domovska/masZajem',
        barva: discipliny['Stezka']!.barva,
        extra: discipliny['Stezka']),
    Ikona(
        popisek: discipliny['Shyby']!.nazev,
        ikona: FontAwesomeIcons.weightHanging,
        proklik: '/domovska/masZajem',
        barva: discipliny['Shyby']!.barva,
        extra: discipliny['Shyby']),
    Ikona(
        popisek: discipliny['Granáty']!.nazev,
        ikona: FontAwesomeIcons.bomb,
        proklik: '/domovska/masZajem',
        barva: discipliny['Granáty']!.barva,
        extra: discipliny['Granáty']),
    Ikona(
        popisek: discipliny['Lano']!.nazev,
        ikona: Icons.question_mark,
        proklik: '/domovska/masZajem',
        barva: discipliny['Lano']!.barva,
        extra: discipliny['Lano']),
    Ikona(
        popisek: discipliny['Úklid']!.nazev,
        ikona: FontAwesomeIcons.broom,
        proklik: '/domovska/masZajem',
        barva: discipliny['Úklid']!.barva,
        extra: discipliny['Úklid']),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      children: ikony,
    );
  }
}
