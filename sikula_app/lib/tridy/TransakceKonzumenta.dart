import 'package:sikula/tridy/Konzument.dart';

class TransakceKonzumenta {
  final int id;
  final DateTime datumAcas;
  final Konzument? konzument;
  final String nadpis;
  final String vyridil;
  final double? cena;
  final String? poznamka;

  TransakceKonzumenta(
      {required this.id,
      required this.datumAcas,
      this.konzument,
      required this.nadpis,
      required this.vyridil,
      required this.cena,
      required this.poznamka});
}
