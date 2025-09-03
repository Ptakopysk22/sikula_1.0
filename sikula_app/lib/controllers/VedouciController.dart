import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikula/modely/VedoucilModel.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/BankovniUcet.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

class VedouciController {
  VedoucilModel vedoucilModel = VedoucilModel();

  Future<Vedouci> vratVedouciho(User uzivatel) async {
    Vedouci aktualniVedouci = await vedoucilModel.vratVedouciho(uzivatel);
    //zde ukládám aktualně přihlášeného vedoucího do statické třídy
    AktualniVedouci.vedouci = aktualniVedouci;
    return aktualniVedouci;
  }

  Future<Vedouci> vratAktualnihoVedouciho(Vedouci vedouci) async {
    Vedouci aktualniVedouci =
        await vedoucilModel.vratAktualnihoVedouciho(vedouci);
    return aktualniVedouci;
  }

    Future<Vedouci> vratVedoucihoDleKonzumenta(Konzument konzument) async {
    Vedouci vedouci =
        await vedoucilModel.vratVedoucihoDleKonzumenta(konzument);
    return vedouci;
  }


  Future<String> pridejVedouciho(
      String prezdivka, String email, String funkce) async {
    String hlaska =
        await vedoucilModel.pridejVedouciho(prezdivka, email, funkce);
    return hlaska;
  }

  Future<List<Vedouci>> vratSeznamVedoucich() async {
    List<Vedouci> seznamVedoucich = await vedoucilModel.vratSeznamVedoucich();
    return seznamVedoucich;
  }

  Future<String> upravVedouciho(
      int id, String prezdivka, String email, String funkce) async {
    String hlaska =
        await vedoucilModel.upravVedouciho(id, prezdivka, email, funkce);
    return hlaska;
  }

  Future<BankovniUcet?> vratBankovniUcet(Vedouci? vedouci) async {
    BankovniUcet? bankovniUcet = await vedoucilModel.vratBankovniUcet(vedouci);
    return bankovniUcet;
  }

  Future<String> upravUcet(
      Vedouci vedouci, String zakladniCast, String kodBanky) async {
    String hlaska =
        await vedoucilModel.upravUcet(vedouci, zakladniCast, kodBanky);
    return hlaska;
  }
}
