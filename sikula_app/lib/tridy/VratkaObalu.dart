import 'package:sikula/tridy/DruhObalu.dart';
import 'package:sikula/tridy/Ucet.dart';

class VratkaObalu {
  final int id;
  final DateTime? datumAcas;
  final int? kusu;
  final DruhObalu? druh;
  //final double? castka;
  final Ucet? ucet;
  final String? vyridil;
  final String? poznamka;

  VratkaObalu({required this.id, required this.datumAcas, required this.kusu, required this.druh, required this.ucet, required this.vyridil,required this.poznamka});
}