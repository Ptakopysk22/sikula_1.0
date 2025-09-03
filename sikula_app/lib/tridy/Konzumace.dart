import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Polozka.dart';

class Konzumace {
  final int id;
  final DateTime datumAcas;
  final Konzument? konzument;
  final Polozka polozka;
  final Konzument carkujici;
  final double? cena;
  final int kusu;
  final String? poznamka;

  Konzumace(
      {required this.id,
      required this.datumAcas,
      required this.konzument,
      required this.polozka,
      required this.carkujici,
      required this.cena,
      required this.kusu,
      required this.poznamka});
}
