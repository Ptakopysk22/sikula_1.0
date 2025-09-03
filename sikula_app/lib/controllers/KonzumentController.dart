import 'package:sikula/modely/KonzumentModel.dart';
import 'package:sikula/tridy/Konzumace.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/TransakceKonzumenta.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zaloha.dart';

class KonzumentController {
  KonzumentModel konzumentModel = KonzumentModel();

  Future<List<Konzument>> vratSeznamKonzumentu() async {
    List<Konzument> seznamKonzumentu =
        await konzumentModel.vratSeznamKonzumentu();
    return seznamKonzumentu;
  }

  Future<String> pridejKonzumenta(Vedouci? vedouci, String cip) async {
    String hlaska = await konzumentModel.pridejKonzumenta(vedouci, cip);
    return hlaska;
  }

  Future<String> upravCip(Vedouci? vedouci, String cip) async {
    String hlaska = await konzumentModel.upravCip(vedouci, cip);
    return hlaska;
  }

  Future<String> pridejZalohu(
      Konzument konzument, double? castka, Ucet? ucet, String? poznamka) async {
    String hlaska =
        await konzumentModel.pridejZalohu(konzument, castka, ucet, poznamka);
    return hlaska;
  }

  Future<String> upravZalohu(int id, Konzument konzument, double? castka,
      Ucet? ucet, String? poznamka) async {
    String hlaska =
        await konzumentModel.upravZalohu(id, konzument, castka, ucet, poznamka);
    return hlaska;
  }

  Future<List<Zaloha>> vratSeznamZaloh(Konzument zobrazovanyKonzument) async {
    List<Zaloha> seznamZaloh =
        await konzumentModel.vratSeznamZaloh(zobrazovanyKonzument);
    return seznamZaloh;
  }

  Future<Zaloha> vratZalohu(int zalohaID) async {
    Zaloha zaloha = await konzumentModel.vratZalohu(zalohaID);
    return zaloha;
  }

  Future<List<Konzumace>> vratVsechnyKonzumace() async {
    List<Konzumace> vsechnyKonzumace =
        await konzumentModel.vratVsechnyKonzumace();
    return vsechnyKonzumace;
  }

  Future<List<Konzumace>> vratKonzumaceKonzumenta(Konzument konzument) async {
    List<Konzumace> konzumaceKonzumenta =
        await konzumentModel.vratKonzumaceKonzumenta(konzument);
    return konzumaceKonzumenta;
  }

  Future<Konzument> vratKonzumenta(int? konzumentID) async {
    Konzument aktualizovanyKonzument =
        await konzumentModel.vratKonzumenta(konzumentID);
    return aktualizovanyKonzument;
  }

    Future<Konzument?> vratKonzumentaDleCipu(String? cip) async {
    Konzument? aktualizovanyKonzument =
        await konzumentModel.vratKonzumentaDleCipu(cip);
    return aktualizovanyKonzument;
  }

  Future<List<TransakceKonzumenta>> vratTransakceKonzumenta(
      Konzument konzument) async {
    List<TransakceKonzumenta> transakceKonzumenta = [];
    List<Konzumace> konzumaceKonzumenta =
        await vratKonzumaceKonzumenta(konzument);
    for (var konzumace in konzumaceKonzumenta) {
      transakceKonzumenta.add(TransakceKonzumenta(
          id: konzumace.id,
          datumAcas: konzumace.datumAcas,
          nadpis: '${konzumace.kusu}ks ${konzumace.polozka.nazev}',
          vyridil: konzumace.carkujici.prezdivka,
          cena: konzumace.cena,
          poznamka: konzumace.poznamka));
    }
    List<Zaloha> seznamZaloh = await vratSeznamZaloh(konzument);
    for (var zaloha in seznamZaloh) {
      transakceKonzumenta.add(TransakceKonzumenta(
          id: zaloha.id,
          datumAcas: zaloha.datumAcas!,
          nadpis: zaloha.castka! >= 0 ? 'Vložení zálohy' : 'Vratka přeplatku',
          vyridil: zaloha.vyridil!,
          cena: zaloha.castka,
          poznamka: zaloha.poznamka));
    }
    //obrácené řezení - nejnovješí nahoře
    transakceKonzumenta.sort((b, a) => a.datumAcas.compareTo(b.datumAcas));
    return transakceKonzumenta;
  }
}
