import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Konzumace.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zaloha.dart';

class KonzumentModel {
  Connection? pripojeni;

  Future<List<Konzument>> vratSeznamKonzumentu() async {
    List<Konzument> seznamKonzumentu = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamVedoucichTx) async {
        final seznamRaw = await seznamVedoucichTx.execute(Sql.named(
            'SELECT k.id, v.prezdivka AS id_vedouci, k.cip, k.kredit, k.zkonzumovanych_kusu, k.nacarkovanych_kusu FROM public.konzumenti k INNER JOIN public.vedouci v ON k.id_vedouci = v.id ORDER BY k.id'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          String prezdivka = radek[1] as String;
          String cip = radek[2] as String;
          double? kredit = double.tryParse(radek[3] as String);
          int zkonzumovanychKusu = radek[4] as int;
          int nacarkovavanychKusu = radek[5] as int;
          seznamKonzumentu.add(Konzument(
              id: id,
              prezdivka: prezdivka,
              cip: cip,
              kredit: kredit,
              zkonzumovanychKusu: zkonzumovanychKusu,
              nacarkovanychKusu: nacarkovavanychKusu));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return seznamKonzumentu;
  }

  Future<String> pridejKonzumenta(Vedouci? vedouci, String cip) async {
    String stavNovyKonzument = '';
    String? prezdivka;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((konzumentTx) async {
        //nesmí být přiřezen jeden čip více konzumentům
        if (cip != 'Bez čipu') {
          final seznamRaw = await konzumentTx.execute(
              Sql.named(
                  'SELECT v.prezdivka FROM public.konzumenti k LEFT JOIN public.vedouci v ON v.id = k.id_vedouci WHERE cip = @cip'),
              parameters: {'cip': cip});
          for (var radek in seznamRaw) {
            prezdivka = radek[0] as String?;
          }
          if (prezdivka != null) {
            return stavNovyKonzument =
                'Tento čip patří konzumentovi: $prezdivka';
          }
        }
        Result novyKonzumentVysledek = await konzumentTx.execute(
            Sql.named(
                'INSERT INTO public.konzumenti(id_vedouci, cip, kredit, zkonzumovanych_kusu, nacarkovanych_kusu) VALUES (@id_vedouci, @cip, @kredit, @zkonzumovanych_kusu, @nacarkovanych_kusu)'),
            parameters: {
              'id_vedouci': vedouci!.id,
              'cip': cip,
              'kredit': 0,
              'zkonzumovanych_kusu': 0,
              'nacarkovanych_kusu': 0,
            });
        stavNovyKonzument = (novyKonzumentVysledek.affectedRows > 0
            ? 'konzument pridan'
            : 'chyba15');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavNovyKonzument;
  }

  Future<String> upravCip(Vedouci? vedouci, String cip) async {
    String stavUpravenyKonzument = '';
    String? prezdivka;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((konzumentTx) async {
        //nesmí být přiřezen jeden čip více konzumentům
        if (cip != 'Bez čipu') {
          final seznamRaw = await konzumentTx.execute(
              Sql.named(
                  'SELECT v.prezdivka FROM public.konzumenti k LEFT JOIN public.vedouci v ON v.id = k.id_vedouci WHERE cip = @cip'),
              parameters: {'cip': cip});
          for (var radek in seznamRaw) {
            prezdivka = radek[0] as String?;
          }
          if (prezdivka != null) {
            return stavUpravenyKonzument =
                'Tento čip patří konzumentovi: $prezdivka';
          }
        }
        Result novyKonzumentVysledek = await konzumentTx.execute(
            Sql.named(
                'UPDATE public.konzumenti SET cip = @cip WHERE id_vedouci = @id_vedouci;'),
            parameters: {
              'id_vedouci': vedouci!.id,
              'cip': cip,
            });
        stavUpravenyKonzument = (novyKonzumentVysledek.affectedRows > 0
            ? 'cip upraven'
            : 'chyba16');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavUpravenyKonzument;
  }

  Future<String> pridejZalohu(
      Konzument konzument, double? castka, Ucet? ucet, String? poznamka) async {
    String stavZalohy = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((zalohaTx) async {
        Result zalohaVysledek = await zalohaTx.execute(
            Sql.named(
                'INSERT INTO public.zalohy(id_konzument ,datum_cas, castka, id_ucet, id_vyridil, poznamka) VALUES (@id_konzument, @datum_cas, @castka, @id_ucet, @id_vyridil, @poznamka)'),
            parameters: {
              'id_konzument': konzument.id,
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'castka': castka,
              'id_ucet': ucet!.id,
              'id_vyridil': AktualniVedouci.vedouci?.id,
              'poznamka': poznamka,
            });
        stavZalohy =
            (zalohaVysledek.affectedRows > 0 ? 'zaloha pridana' : 'chyba5');
      });
    } catch (e) {
      print('tady');
      print('Něco se nepovedlo: $e');
    }
    return stavZalohy;
  }

  Future<String> upravZalohu(int id, Konzument konzument, double? castka,
      Ucet? ucet, String? poznamka) async {
    String stavZalohy = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((zalohaTx) async {
        Result zalohaVysledek = await zalohaTx.execute(
            Sql.named(
                'UPDATE public.zalohy SET id_konzument = @id_konzument, castka = @castka, id_ucet = @id_ucet, poznamka = @poznamka WHERE id = @id'),
            parameters: {
              'id_konzument': konzument.id,
              //'datum_cas':
              //    DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()),
              'castka': castka,
              'id_ucet': ucet!.id,
              'poznamka': poznamka,
              //'id_vyridil': AktualniVedouci.vedouci?.id,
              'id': id,
            });
        stavZalohy =
            (zalohaVysledek.affectedRows > 0 ? 'zaloha upravena' : 'chyba12');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavZalohy;
  }

  Future<List<Zaloha>> vratSeznamZaloh(Konzument zobrazovanyKonzument) async {
    List<Zaloha> seznamZaloh = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamZalohTx) async {
        final seznamRaw = await seznamZalohTx.execute(
            Sql.named(
                'SELECT z.id, z.datum_cas, z.castka, z.id_ucet, u.nazev, v.prezdivka, z.poznamka FROM public.zalohy z INNER JOIN public.ucty u ON z.id_ucet = u.id INNER JOIN public.vedouci v ON z.id_vyridil = v.id WHERE z.id_konzument = @id_konzument ORDER BY z.id DESC'),
            parameters: {'id_konzument': zobrazovanyKonzument.id});
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          double? castka = double.tryParse(radek[2] as String);
          int idUcet = radek[3] as int;
          String ucetNazev = radek[4] as String;
          String vyridil = radek[5] as String;
          String? poznamka = radek[6] as String?;
          seznamZaloh.add(Zaloha(
              id: id,
              konzument: zobrazovanyKonzument,
              datumAcas: datumAcas,
              castka: castka,
              ucet: Ucet(id: idUcet, nazev: ucetNazev),
              vyridil: vyridil,
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return seznamZaloh;
  }

  Future<Zaloha> vratZalohu(int zalohaID) async {
    late Zaloha zaloha;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamZalohTx) async {
        final seznamRaw = await seznamZalohTx.execute(
            Sql.named(
                'SELECT z.id, z.datum_cas, z.castka, z.id_ucet, u.nazev, v.prezdivka AS vyridil_prezdivka, z.poznamka, z.id_konzument, v_konzument.prezdivka AS konzument_prezdivka, k.kredit FROM public.zalohy z INNER JOIN public.ucty u ON z.id_ucet = u.id INNER JOIN public.vedouci v ON z.id_vyridil = v.id INNER JOIN public.konzumenti k ON z.id_konzument = k.id INNER JOIN public.vedouci v_konzument ON k.id_vedouci = v_konzument.id WHERE z.id = @id LIMIT 1;'),
            parameters: {'id': zalohaID});
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          double? castka = double.tryParse(radek[2] as String);
          int idUcet = radek[3] as int;
          String ucetNazev = radek[4] as String;
          String vyridil = radek[5] as String;
          String? poznamka = radek[6] as String?;
          int konzumentId = radek[7] as int;
          String konzumentPrazdivka = radek[8] as String;
          double? kredit = double.tryParse(radek[9] as String);
          zaloha = Zaloha(
              id: id,
              konzument: Konzument(
                  id: konzumentId,
                  prezdivka: konzumentPrazdivka,
                  kredit: kredit),
              datumAcas: datumAcas,
              castka: castka,
              ucet: Ucet(id: idUcet, nazev: ucetNazev),
              vyridil: vyridil,
              poznamka: poznamka);
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return zaloha;
  }

  Future<List<Konzumace>> vratVsechnyKonzumace() async {
    List<Konzumace> vsechnyKonzumace = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamKonzumaciTx) async {
        final seznamRaw = await seznamKonzumaciTx.execute(Sql.named(
            'SELECT k.id, k.datum_cas, k.id_konzument, v_konzument.prezdivka AS konzument_prezdivka, k.id_polozka, p.nazev, k.id_carkujici, v_carkujici.prezdivka AS carkujici_prezdivka, k.pevna_cena, k.kusu, k.poznamka FROM public.konzumace k INNER JOIN public.polozky p ON k.id_polozka = p.id INNER JOIN public.konzumenti kz_carkujici ON k.id_carkujici = kz_carkujici.id INNER JOIN public.vedouci v_carkujici ON kz_carkujici.id_vedouci = v_carkujici.id INNER JOIN public.konzumenti kz ON k.id_konzument = kz.id INNER JOIN public.vedouci v_konzument ON kz.id_vedouci = v_konzument.id ORDER BY k.id DESC;'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          int konzumentID = radek[2] as int;
          String konzumentPrezdivka = radek[3] as String;
          int polozkaID = radek[4] as int;
          String polozkaNazev = radek[5] as String;
          int carkujiciID = radek[6] as int;
          String carkujiciPrezdivka = radek[7] as String;
          double? cena = double.tryParse(radek[8] as String);
          int kusu = radek[9] as int;
          String? poznamka = radek[10] as String?;
          vsechnyKonzumace.add(Konzumace(
              id: id,
              datumAcas: datumAcas,
              konzument:
                  Konzument(id: konzumentID, prezdivka: konzumentPrezdivka),
              polozka: Polozka(id: polozkaID, nazev: polozkaNazev),
              carkujici:
                  Konzument(id: carkujiciID, prezdivka: carkujiciPrezdivka),
              cena: cena,
              kusu: kusu,
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return vsechnyKonzumace;
  }

  Future<List<Konzumace>> vratKonzumaceKonzumenta(Konzument konzument) async {
    List<Konzumace> konzumaceKonzumenta = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamKonzumaciTx) async {
        final seznamRaw = await seznamKonzumaciTx.execute(
            Sql.named(
                'SELECT k.id, k.datum_cas, k.id_polozka, p.nazev, k.id_carkujici, v_carkujici.prezdivka AS carkujici_prezdivka, k.pevna_cena, k.kusu, k.poznamka, v_konzument.prezdivka AS konzument_prezdivka FROM public.konzumace k INNER JOIN public.polozky p ON k.id_polozka = p.id INNER JOIN public.konzumenti kz_carkujici ON k.id_carkujici = kz_carkujici.id INNER JOIN public.vedouci v_carkujici ON kz_carkujici.id_vedouci = v_carkujici.id INNER JOIN public.konzumenti kz ON k.id_konzument = kz.id INNER JOIN public.vedouci v_konzument ON kz.id_vedouci = v_konzument.id WHERE k.id_konzument = @id_konzument ORDER BY k.id DESC;'),
            parameters: {'id_konzument': konzument.id});
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          int polozkaID = radek[2] as int;
          String polozkaNazev = radek[3] as String;
          int carkujiciID = radek[4] as int;
          String carkujiciPrezdivka = radek[5] as String;
          double? cena = double.tryParse(radek[6] as String);
          int kusu = radek[7] as int;
          String? poznamka = radek[8] as String?;
          konzumaceKonzumenta.add(Konzumace(
              id: id,
              datumAcas: datumAcas,
              konzument:
                  Konzument(id: konzument.id, prezdivka: konzument.prezdivka),
              polozka: Polozka(id: polozkaID, nazev: polozkaNazev),
              carkujici:
                  Konzument(id: carkujiciID, prezdivka: carkujiciPrezdivka),
              cena: cena,
              kusu: kusu,
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return konzumaceKonzumenta;
  }

  Future<Konzument> vratKonzumenta(int? konzumentID) async {
    late Konzument aktualizovanyKonzument;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamVedoucichTx) async {
        final seznamRaw = await seznamVedoucichTx.execute(
            Sql.named(
                'SELECT k.id, v.prezdivka AS id_vedouci, k.cip, k.kredit, k.zkonzumovanych_kusu, k.nacarkovanych_kusu FROM public.konzumenti k INNER JOIN public.vedouci v ON k.id_vedouci = v.id WHERE k.id = @id'),
            parameters: {'id': konzumentID});
        if (seznamRaw.isNotEmpty) {
          var radek = seznamRaw.first;
          int id = radek[0] as int;
          String prezdivka = radek[1] as String;
          String cip = radek[2] as String;
          double? kredit = double.tryParse(radek[3] as String);
          int zkonzumovanychKusu = radek[4] as int;
          int nacarkovavanychKusu = radek[5] as int;
          aktualizovanyKonzument = Konzument(
              id: id,
              prezdivka: prezdivka,
              cip: cip,
              kredit: kredit,
              zkonzumovanychKusu: zkonzumovanychKusu,
              nacarkovanychKusu: nacarkovavanychKusu);
        } else {
          throw Exception('Konzument nenalezen');
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
      throw Exception('Chyba při načítání konzumenta');
    }
    return aktualizovanyKonzument;
  }
  
  Future<Konzument?> vratKonzumentaDleCipu(String? cip) async {
    late Konzument? aktualizovanyKonzument;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamVedoucichTx) async {
        final seznamRaw = await seznamVedoucichTx.execute(
            Sql.named(
                'SELECT k.id, v.prezdivka AS id_vedouci, k.cip, k.kredit, k.zkonzumovanych_kusu, k.nacarkovanych_kusu FROM public.konzumenti k INNER JOIN public.vedouci v ON k.id_vedouci = v.id WHERE k.cip = @cip'),
            parameters: {'cip': cip});
        if (seznamRaw.isNotEmpty) {
          var radek = seznamRaw.first;
          int id = radek[0] as int;
          String prezdivka = radek[1] as String;
          String cip = radek[2] as String;
          double? kredit = double.tryParse(radek[3] as String);
          int zkonzumovanychKusu = radek[4] as int;
          int nacarkovavanychKusu = radek[5] as int;
          aktualizovanyKonzument = Konzument(
              id: id,
              prezdivka: prezdivka,
              cip: cip,
              kredit: kredit,
              zkonzumovanychKusu: zkonzumovanychKusu,
              nacarkovanychKusu: nacarkovavanychKusu);
        } else {
          aktualizovanyKonzument = null;
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
      throw Exception('Chyba při načítání konzumenta');
    }
    return aktualizovanyKonzument;
  }
}

