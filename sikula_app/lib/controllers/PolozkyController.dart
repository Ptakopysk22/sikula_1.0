import 'package:sikula/modely/PolozkaModel.dart';
import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Korekce.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/VratkaObalu.dart';

class PolozkyController {
  PolozkaModel polozkaModel = PolozkaModel();

  Future<String> pridejPolozku(
      String? nazev,
      int? nakoupeneKusy,
      double? nakupniCena,
      double? prodejniCena,
      Kategorie? kategorie,
      Ucet? ucet,
      String? poznamka) async {
    String hlaska = await polozkaModel.pridejPolozku(nazev, nakoupeneKusy,
        nakupniCena, prodejniCena, kategorie, ucet, poznamka);
    return hlaska;
  }

  Future<List<Polozka>> vratSeznamPolozek() async {
    List<Polozka> seznamPolozek = await polozkaModel.vratSeznamPolozek();
    return seznamPolozek;
  }

  Future<String> upravPolozku(
      int id,
      String? nazev,
      int? nakoupeneKusy,
      double? nakupniCena,
      double? prodejniCena,
      Kategorie? kategorie,
      Ucet? ucet,
      String? poznamka) async {
    String hlaska = await polozkaModel.upravPolozku(id, nazev, nakoupeneKusy,
        nakupniCena, prodejniCena, kategorie, ucet, poznamka);
    return hlaska;
  }

  Future<String> nacarkujuPolozku(
    Konzument konzument,
    Konzument? carkujici,
    Polozka? polozka,
    int? kusy,
  ) async {
    String hlaska =
        await polozkaModel.nacarkujPolozku(konzument, carkujici, polozka, kusy);
    return hlaska;
  }

  Future<List<Polozka>> vratNabidkuPolozek() async {
    List<Polozka> nabidkaPolozek = await polozkaModel.vratNabidkuPolozek();
    return nabidkaPolozek;
  }

  Future<Polozka> vratPolozku(int polozkaID) async {
    Polozka polozka = await polozkaModel.vratPolozku(polozkaID);
    return polozka;
  }

  Future<List<VratkaObalu>> vratVratkyObalu() async {
    List<VratkaObalu> vratkyObalu = await polozkaModel.vratVratkyObalu();
    return vratkyObalu;
  }

  Future<String> pridejObal(
      String? druh, int? kusu, Ucet? ucet, String? poznamka) async {
    String hlaska = await polozkaModel.pridejObal(druh, kusu, ucet, poznamka);
    return hlaska;
  }

  Future<String> upravObal(
      int id, String? druh, int? kusu, Ucet? ucet, String? poznamka) async {
    String hlaska =
        await polozkaModel.upravObal(id, druh, kusu, ucet, poznamka);
    return hlaska;
  }

  Future<VratkaObalu> vratVratkuObalu(int vratkaObaluID) async {
    VratkaObalu vratkaObalu = await polozkaModel.vratVratkuObalu(vratkaObaluID);
    return vratkaObalu;
  }

  Future<String> upravKonzumaci(int id, Polozka? polozka, Konzument? konzument,
      Konzument? carkujici, double? cena, int? kusy, String poznamka) async {
    String hlaska = await polozkaModel.upravKonzumaci(
        id, polozka, konzument, carkujici, cena, kusy, poznamka);
    return hlaska;
  }

  Future<List<Polozka>> vratPolozkyVeSklipku() async {
    List<Polozka> polozkyVeSklipku = await polozkaModel.vratPolozkyVeSklipku();
    return polozkyVeSklipku;
  }

  Future<String> pridejKorekci(
      Polozka polozka, int? realnyPocetKusu, String poznamka) async {
    int rozdilKusu = realnyPocetKusu! - polozka.zbyvajiciKusy!;
    String hlaska =
        await polozkaModel.pridejKorekci(polozka, rozdilKusu, poznamka);
    return hlaska;
  }

  Future<List<Korekce>> vratKorekce() async {
    List<Korekce> seznamKorekci = await polozkaModel.vratKorekce();
    return seznamKorekci;
  }
}
