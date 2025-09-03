import 'package:sikula/tridy/BankovniUcet.dart';
import 'package:sikula/tridy/Konzument.dart';

class Vedouci {
  final int id;
  final String prezdivka;
  final String email;
  final String? funkce;
  late Konzument? konzument;
  late BankovniUcet? bankovniUcet;

  Vedouci(
      {required this.id,
      required this.prezdivka,
      required this.email,
      required this.funkce,
      this.konzument,
      this.bankovniUcet});

  vratPrezdivku() {
    return prezdivka;
  }

  vratEmail() {
    return email;
  }

  vratFunkci() {
    return funkce;
  }
}
