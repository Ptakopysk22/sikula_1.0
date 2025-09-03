import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/PokladniZaznam.dart';

class PokladnaModel {
  Connection? pripojeni;

  Future<List<PokladniZaznam>> vratSeznamZaznamu() async {
    List<PokladniZaznam> seznamZaznamu = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((zaznamyTx) async {
        //data z tabulky nákupy
        final zaznamyNakupy = await zaznamyTx.execute(Sql.named(
            'SELECT n.id_polozka, p.datum_cas, p.nazev, n.castka, u.nazev, t.oznaceni, v.prezdivka FROM public.nakupy n INNER JOIN public.polozky p ON n.id_polozka = p.id INNER JOIN public.ucty u ON n.id_ucet = u.id INNER JOIN public.transakce t ON n.id_transakce = t.id INNER JOIN public.vedouci v ON p.id_nakoupil = v.id ORDER BY n.id_polozka DESC;'));
        for (var radek in zaznamyNakupy) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          String nadpis = radek[2] as String;
          double? castka = double.tryParse(radek[3] as String);
          String ucet = radek[4] as String;
          String typTransakce = radek[5] as String;
          String vyridil = radek[6] as String;
          seznamZaznamu.add(PokladniZaznam(
              id: id,
              castka: castka,
              nadpis: nadpis,
              typTransakce: typTransakce,
              ucet: ucet,
              vyridil: vyridil,
              datumAcas: datumAcas));
        }
        //data z tabulky zálohy
        final zaznamyZalohy = await zaznamyTx.execute(Sql.named(
            'SELECT z.id, z.datum_cas, v.prezdivka AS konzument_prezdivka, z.castka, u.nazev, v2.prezdivka AS vyridil_prezdivka FROM public.zalohy z INNER JOIN public.ucty u ON z.id_ucet = u.id INNER JOIN public.konzumenti k ON z.id_konzument = k.id INNER JOIN public.vedouci v ON k.id_vedouci = v.id INNER JOIN public.vedouci v2 ON z.id_vyridil = v2.id ORDER BY z.id DESC;'));
        for (var radek in zaznamyZalohy) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          String nadpis = radek[2] as String;
          double? castka = double.tryParse(radek[3] as String);
          String ucet = radek[4] as String;
          String typTransakce;
          if (castka! >= 0) {
            typTransakce = 'Výběr zálohy';
          } else {
            typTransakce = 'Vratka zálohy';
          }
          String vyridil = radek[5] as String;
          seznamZaznamu.add(PokladniZaznam(
              id: id,
              castka: castka,
              nadpis: nadpis,
              typTransakce: typTransakce,
              ucet: ucet,
              vyridil: vyridil,
              datumAcas: datumAcas));
        }
        //data z tabulky vrácených vratných obalů
        final zaznamyObaly = await zaznamyTx.execute(Sql.named(
            'SELECT o.id, o.datum_cas, o.druh, o.kusu, o.castka, u.nazev, v.prezdivka FROM public.obaly o INNER JOIN public.ucty u ON o.id_ucet = u.id INNER JOIN public.vedouci v ON o.id_vyridil = v.id ORDER BY o.id DESC;'));
        for (var radek in zaznamyObaly) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          String druh = radek[2] as String;
          int kusu = radek[3] as int;
          String nadpis = '${kusu}ks - $druh';
          double? castka = double.tryParse(radek[4] as String);
          String ucet = radek[5] as String;
          String typTransakce;
          if (druh.contains('Lahve')) {
            typTransakce = 'Vratka lahví';
          } else {
            typTransakce = 'Vratka přepravek';
          }
          String vyridil = radek[6] as String;
          seznamZaznamu.add(PokladniZaznam(
              id: id,
              castka: castka,
              nadpis: nadpis,
              typTransakce: typTransakce,
              ucet: ucet,
              vyridil: vyridil,
              datumAcas: datumAcas));
        }
        seznamZaznamu.sort((b, a) => a.datumAcas.compareTo(b.datumAcas));
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return seznamZaznamu;
  }

  Future<String> vratFinancniRezervu() async {
    double financniRezerva = 0;
    double rozdilNakupProdejJisty = 0;
    double rozdilNakupProdejOdhad = 0;
    double rozdilKorekce = 0;
    String financniRezervaText;

    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((financniRezervaTx) async {
        //Data z tabulky konzumace - již jistá finanční rezerva
        final rozdilNakupProdejJistyVysledek = await financniRezervaTx.execute(Sql.named(
            'SELECT SUM(- k.pevna_cena - (p.nakupni_cena * k.kusu)) AS celkovy_soucet FROM konzumace k JOIN polozky p ON k.id_polozka = p.id;'));
        if (rozdilNakupProdejJistyVysledek.isNotEmpty &&
            rozdilNakupProdejJistyVysledek[0][0] != null) {
          rozdilNakupProdejJisty =
              double.tryParse(rozdilNakupProdejJistyVysledek[0][0].toString()) ?? 0;
        }

        //Data z tabulky v nabidce - pouze odhad, pokud se vše prodá za aktuální cenu
        final rozdilNakupProdejOdhadVysledek = await financniRezervaTx.execute(Sql.named(
            'SELECT SUM((p.prodejni_cena - p.nakupni_cena) * n.zbyvajici_kusy) AS celkovy_soucet FROM nabidka n JOIN polozky p ON n.id_polozka = p.id;'));
        if (rozdilNakupProdejOdhadVysledek.isNotEmpty &&
            rozdilNakupProdejOdhadVysledek[0][0] != null) {
          rozdilNakupProdejOdhad =
              double.tryParse(rozdilNakupProdejOdhadVysledek[0][0].toString()) ?? 0;
        }

        // Data z tabulky korekce - záporná hodnota za rozbité a ztracené věci
        final rozdilKorekceVysledek = await financniRezervaTx.execute(Sql.named(
            'WITH constants AS (SELECT zaloha_lahev, zaloha_prepravka FROM public.kategorie WHERE id = 1) SELECT SUM(k.rozdil_kusu * CASE WHEN k.id_polozka = 1 THEN c.zaloha_lahev WHEN k.id_polozka = 2 THEN c.zaloha_prepravka ELSE p.nakupni_cena END) AS celkovy_soucet FROM public.korekce k LEFT JOIN public.polozky p ON k.id_polozka = p.id CROSS JOIN constants c;'));
        if (rozdilKorekceVysledek.isNotEmpty &&
            rozdilKorekceVysledek[0][0] != null) {
          rozdilKorekce =
              double.tryParse(rozdilKorekceVysledek[0][0].toString()) ?? 0;
        }
      });
      financniRezerva = rozdilNakupProdejJisty + rozdilNakupProdejOdhad + rozdilKorekce;
      financniRezervaText = financniRezerva.toStringAsFixed(1);
    } catch (e) {
      print('Něco se nepovedlo: $e');
      financniRezervaText = 'Chyba při načítání finanční rezervy';
    }

    return financniRezervaText;
  }
}
