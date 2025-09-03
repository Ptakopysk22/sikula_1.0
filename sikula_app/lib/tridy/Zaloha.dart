import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Ucet.dart';

class Zaloha {
  final int id;
  final Konzument? konzument;
  final DateTime? datumAcas;
  final double? castka;
  final Ucet? ucet;
  final String? vyridil;
  final String? poznamka;

  Zaloha({required this.id, required this.konzument, required this.datumAcas, required this.castka, required this.ucet, required this.vyridil, required this.poznamka});

}