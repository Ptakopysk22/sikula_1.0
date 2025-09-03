import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Ucet.dart';

class Polozka {
  final int id;
  late DateTime? datumAcas;
  final String? nazev;
  late int? nakoupeneKusy;
  late int? zbyvajiciKusy;
  late double? nakupniCena;
  final double? prodejniCena;
  late Kategorie? kategorie;
  late String? nakoupil;
  late Ucet? ucet;
  late String? poznamka; 
  late bool? vNabidce;
  late int? vybraneKusy;

    Polozka({
    required this.id,
    this.nazev,
    this.zbyvajiciKusy,
    this.prodejniCena,
    this.datumAcas,
    this.nakoupeneKusy,
    this.nakupniCena,
    this.kategorie,
    this.nakoupil,
    this.ucet,
    this.poznamka,
    this.vNabidce,
    this.vybraneKusy
  });

//do budoucna, zeptat se gpt na to jak to změnit aby byly required ale zároven šli nastavit pak jen pomocí metod!
}
