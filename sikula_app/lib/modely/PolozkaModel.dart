import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/DruhObalu.dart';
import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Korekce.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/Ucet.dart';
import 'package:sikula/tridy/VratkaObalu.dart';

class PolozkaModel {

  Future<String> pridejPolozku(
      String? nazev,
      int? nakoupeneKusy,
      double? nakupniCena,
      double? prodejniCena,
      Kategorie? kategorie,
      Ucet? ucet,
      String? poznamka) async {
    String stavNovaPolozka = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((novaPolozkaTx) async {
        Result novaPolozkaVysledek = await novaPolozkaTx.execute(
            Sql.named(
                'INSERT INTO public.polozky(datum_cas, nazev, nakoupene_kusy, nakupni_cena, prodejni_cena, id_kategorie, id_nakoupil, id_ucet, poznamka) VALUES (@datum_cas, @nazev, @nakoupene_kusy, @nakupni_cena, @prodejni_cena, @id_kategorie, @id_nakoupil, @id_ucet, @poznamka)'),
            parameters: {
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'nazev': nazev,
              'nakoupene_kusy': nakoupeneKusy,
              'nakupni_cena': nakupniCena,
              'prodejni_cena': prodejniCena,
              'id_kategorie': kategorie!.id,
              'id_nakoupil': AktualniVedouci.vedouci?.id,
              'id_ucet': ucet!.id,
              'poznamka': poznamka,
            });
        stavNovaPolozka = (novaPolozkaVysledek.affectedRows > 0
            ? 'polozka pridana'
            : 'chyba3');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavNovaPolozka;
  }

  Future<List<Polozka>> vratSeznamPolozek() async {
    List<Polozka> seznamPolozek = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamPolozekTx) async {
        final seznamRaw = await seznamPolozekTx.execute(Sql.named(
            'SELECT p.id, p.datum_cas, p.nazev, p.nakoupene_kusy, p.nakupni_cena, p.prodejni_cena, p.id_kategorie, k.oznaceni AS id_kategorie, v.prezdivka AS id_nakoupil, p.id_ucet, u.nazev AS id_ucet, p.poznamka FROM public.polozky p INNER JOIN public.vedouci v ON p.id_nakoupil = v.id INNER JOIN public.kategorie k ON p.id_kategorie = k.id INNER JOIN public.ucty u ON p.id_ucet = u.id ORDER BY p.id DESC;'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          String nazev = radek[2] as String;
          int nakoupeneKusy = radek[3] as int;
          double? nakupniCena = double.tryParse(radek[4] as String);
          double? prodejniCena = double.tryParse(radek[5] as String);
          int idKategorie = radek[6] as int;
          String oznaceniKategorie = radek[7] as String;
          String nakoupil = radek[8] as String;
          int idUcet = radek[9] as int;
          String nazevUctu = radek[10] as String;
          String poznamka = radek[11]?.toString() ?? '';
          seznamPolozek.add(Polozka(
              id: id,
              datumAcas: datumAcas,
              nazev: nazev,
              nakoupeneKusy: nakoupeneKusy,
              nakupniCena: nakupniCena,
              prodejniCena: prodejniCena,
              //není uplně optimální vracet, jak id tak oznaceni/název, ale tedˇ moc nevím jak to řešit jinak
              kategorie:
                  Kategorie(id: idKategorie, oznaceni: oznaceniKategorie),
              nakoupil: nakoupil,
              ucet: Ucet(id: idUcet, nazev: nazevUctu),
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
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
    String stavUpravenaPolozka = '';
    try {
      pripojeni = await vytvorSpojeni();;
      await pripojeni!.runTx((upravenaPolozkaTx) async {
        Result upravenaPolozkaVysledek = await upravenaPolozkaTx.execute(
            Sql.named(
                'UPDATE public.polozky SET nazev = @nazev, nakoupene_kusy = @nakoupene_kusy, nakupni_cena = @nakupni_cena, prodejni_cena = @prodejni_cena, id_kategorie = @id_kategorie, id_ucet = @id_ucet, poznamka = @poznamka WHERE id = @id'),
            parameters: {
              //'datum_cas':
              //    DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()), to nepůjde měnit
              'nazev': nazev,
              'nakoupene_kusy': nakoupeneKusy,
              'nakupni_cena': nakupniCena,
              'prodejni_cena': prodejniCena,
              'id_kategorie': kategorie!.id,
              //'nakoupil': AktualniVedouci.vedouci?.id, to nepůjde měnit
              'id_ucet': ucet!.id,
              'poznamka': poznamka,
              'id': id,
            });
        stavUpravenaPolozka = (upravenaPolozkaVysledek.affectedRows > 0
            ? 'polozka upravena'
            : 'chyba4');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavUpravenaPolozka;
  }

  Future<List<Polozka>> vratNabidkuPolozek() async {
    List<Polozka> nabidkaPolozek = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((nabidkaPolozekTx) async {
        final seznamRaw = await nabidkaPolozekTx.execute(Sql.named(
            'SELECT n.id_polozka, p.nazev, n.zbyvajici_kusy, p.prodejni_cena FROM public.nabidka n INNER JOIN public.polozky p ON n.id_polozka = p.id WHERE n.v_nabidce = true ORDER BY n.id;'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          String nazev = radek[1] as String;
          int zbyvajiciKusy = radek[2] as int;
          double? prodejniCena = double.tryParse(radek[3] as String);
          nabidkaPolozek.add(Polozka(
              id: id,
              nazev: nazev,
              zbyvajiciKusy: zbyvajiciKusy,
              prodejniCena: prodejniCena,
              vybraneKusy: 0));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return nabidkaPolozek;
  }

  Future<List<Polozka>> vratPolozkyVeSklipku() async {
    List<Polozka> polozkyVeSklipku = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((nabidkaPolozekTx) async {
        final seznamRaw = await nabidkaPolozekTx.execute(
            Sql.named('SELECT * FROM public.obaly_sklipek ORDER BY id;'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          String nazev = radek[1] as String;
          int zbyvajiciKusy = radek[2] as int;
          double prodejniCena = nazev.contains('Prázdné lahve') ? 3 : 100;
          polozkyVeSklipku.add(Polozka(
              id: id,
              nazev: nazev,
              zbyvajiciKusy: zbyvajiciKusy,
              prodejniCena: prodejniCena,
              vNabidce: false));
        }
        final seznamRaw2 = await nabidkaPolozekTx.execute(Sql.named(
            'SELECT n.id_polozka, p.nazev, n.zbyvajici_kusy, p.prodejni_cena, n.v_nabidce FROM public.nabidka n INNER JOIN public.polozky p ON n.id_polozka = p.id ORDER BY n.id DESC;'));
        for (var radek in seznamRaw2) {
          int id = radek[0] as int;
          String nazev = radek[1] as String;
          int zbyvajiciKusy = radek[2] as int;
          double? prodejniCena = double.tryParse(radek[3] as String);
          bool vNabidce = radek[4] as bool;
          polozkyVeSklipku.add(Polozka(
              id: id,
              nazev: nazev,
              zbyvajiciKusy: zbyvajiciKusy,
              prodejniCena: prodejniCena,
              vNabidce: vNabidce));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return polozkyVeSklipku;
  }

  Future<String> nacarkujPolozku(Konzument konzument, Konzument? carkujici,
      Polozka? polozka, int? kusy) async {
    String stavNacarkovanaPolozka = '';
    //tak aby byla cena záporná!
    double finalniCena = kusy! * polozka!.prodejniCena! * -1;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((nacarkovanaPolozkaTx) async {
        Result macarkovanaPolozkaVysledek = await nacarkovanaPolozkaTx.execute(
            Sql.named(
                'INSERT INTO public.konzumace(datum_cas, id_konzument, id_carkujici, id_polozka, kusu, pevna_cena) VALUES (@datum_cas, @id_konzument, @id_carkujici, @id_polozka, @kusu, @pevna_cena)'),
            parameters: {
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'id_konzument': konzument.id,
              'id_carkujici': carkujici!.id,
              'id_polozka': polozka.id,
              'kusu': kusy,
              'pevna_cena': finalniCena,
            });
        stavNacarkovanaPolozka = (macarkovanaPolozkaVysledek.affectedRows > 0
            ? 'polozka nacarkovana'
            : 'chyba6');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavNacarkovanaPolozka;
  }

  Future<Polozka> vratPolozku(int polozkaID) async {
    late Polozka polozka;
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((polozkakTx) async {
        final seznamRaw = await polozkakTx.execute(
            Sql.named(
                'SELECT p.id, p.datum_cas, p.nazev, p.nakoupene_kusy, p.nakupni_cena, p.prodejni_cena, p.id_kategorie, k.oznaceni AS id_kategorie, v.prezdivka AS id_nakoupil, p.id_ucet, u.nazev AS id_ucet, p.poznamka FROM public.polozky p INNER JOIN public.vedouci v ON p.id_nakoupil = v.id INNER JOIN public.kategorie k ON p.id_kategorie = k.id INNER JOIN public.ucty u ON p.id_ucet = u.id WHERE p.id = @id LIMIT 1;'),
            parameters: {'id': polozkaID});
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          String nazev = radek[2] as String;
          int nakoupeneKusy = radek[3] as int;
          double? nakupniCena = double.tryParse(radek[4] as String);
          double? prodejniCena = double.tryParse(radek[5] as String);
          int idKategorie = radek[6] as int;
          String oznaceniKategorie = radek[7] as String;
          String nakoupil = radek[8] as String;
          int idUcet = radek[9] as int;
          String nazevUctu = radek[10] as String;
          String poznamka = radek[11]?.toString() ?? '';
          polozka = Polozka(
              id: id,
              datumAcas: datumAcas,
              nazev: nazev,
              nakoupeneKusy: nakoupeneKusy,
              nakupniCena: nakupniCena,
              prodejniCena: prodejniCena,
              //není uplně optimální vracet, jak id tak oznaceni/název, ale tedˇ moc nevím jak to řešit jinak
              kategorie:
                  Kategorie(id: idKategorie, oznaceni: oznaceniKategorie),
              nakoupil: nakoupil,
              ucet: Ucet(id: idUcet, nazev: nazevUctu),
              poznamka: poznamka);
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return polozka;
  }

  Future<List<VratkaObalu>> vratVratkyObalu() async {
    List<VratkaObalu> vratkyObalu = [];
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((vratkyObaluTx) async {
        final seznamRaw = await vratkyObaluTx.execute(Sql.named(
            'SELECT o.id, o.datum_cas, o.kusu, o.druh, o.id_ucet, u.nazev, v.prezdivka, o.poznamka FROM public.obaly o INNER JOIN public.vedouci v ON o.id_vyridil = v.id INNER JOIN public.ucty u ON o.id_ucet = u.id ORDER BY o.id DESC;'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          int kusu = radek[2] as int;
          String druhText = radek[3] as String;
          if (druhText.contains('Přepravky')) {
            druhText = 'Prepravky';
          }
          DruhObalu druh = DruhObaluExtension.fromString(druhText);
          int idUcet = radek[4] as int;
          String nazevUctu = radek[5] as String;
          String vyridil = radek[6] as String;
          String poznamka = radek[7]?.toString() ?? '';
          vratkyObalu.add(VratkaObalu(
              id: id,
              datumAcas: datumAcas,
              kusu: kusu,
              druh: druh,
              ucet: Ucet(id: idUcet, nazev: nazevUctu),
              vyridil: vyridil,
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return vratkyObalu;
  }

  Future<String> pridejObal(
      String? druh, int? kusu, Ucet? ucet, String? poznamka) async {
    String stavNovyObal = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((novyObalTx) async {
        Result novyObalVysledek = await novyObalTx.execute(
            Sql.named(
                'INSERT INTO public.obaly(datum_cas, kusu, druh, id_vyridil, id_ucet, poznamka) VALUES (@datum_cas, @kusu, @druh, @id_vyridil, @id_ucet, @poznamka)'),
            parameters: {
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'kusu': kusu,
              'druh': druh,
              'id_vyridil': AktualniVedouci.vedouci?.id,
              'id_ucet': ucet!.id,
              'poznamka': poznamka,
            });
        stavNovyObal =
            (novyObalVysledek.affectedRows > 0 ? 'obal pridana' : 'chyba8');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavNovyObal;
  }

  Future<String> upravObal(
      int id, String? druh, int? kusu, Ucet? ucet, String? poznamka) async {
    String stavUpravenyObal = '';
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((upravenyObalTx) async {
        Result upravenyObalVysledek = await upravenyObalTx.execute(
            Sql.named(
                'UPDATE public.obaly SET kusu = @kusu, druh = @druh, id_ucet = @id_ucet, poznamka = @poznamka WHERE id = @id'),
            parameters: {
              //'datum_cas':
              //    DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now()),
              'kusu': kusu,
              'druh': druh,
              //'id_vyridil': AktualniVedouci.vedouci?.id,
              'id_ucet': ucet!.id,
              'poznamka': poznamka,
              'id': id,
            });
        stavUpravenyObal =
            (upravenyObalVysledek.affectedRows > 0 ? 'obal upraven' : 'chyba9');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavUpravenyObal;
  }

  Future<VratkaObalu> vratVratkuObalu(int vratkaObaluID) async {
    late VratkaObalu vratkaObalu;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((vratkaObaluTx) async {
        final seznamRaw = await vratkaObaluTx.execute(
            Sql.named(
                'SELECT o.id, o.datum_cas, o.kusu, o.druh, o.id_ucet, u.nazev, v.prezdivka, o.poznamka FROM public.obaly o INNER JOIN public.vedouci v ON o.id_vyridil = v.id INNER JOIN public.ucty u ON o.id_ucet = u.id WHERE o.id = @id LIMIT 1;'),
            parameters: {'id': vratkaObaluID});
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          int kusu = radek[2] as int;
          String druhText = radek[3] as String;
          if (druhText.contains('Přepravky')) {
            druhText = 'Prepravky';
          }
          DruhObalu druh = DruhObaluExtension.fromString(druhText);
          int idUcet = radek[4] as int;
          String nazevUctu = radek[5] as String;
          String vyridil = radek[6] as String;
          String poznamka = radek[7]?.toString() ?? '';
          vratkaObalu = VratkaObalu(
              id: id,
              datumAcas: datumAcas,
              kusu: kusu,
              druh: druh,
              ucet: Ucet(id: idUcet, nazev: nazevUctu),
              vyridil: vyridil,
              poznamka: poznamka);
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return vratkaObalu;
  }

  Future<String> upravKonzumaci(int id, Polozka? polozka, Konzument? konzument,
      Konzument? carkujici, double? cena, int? kusy, String poznamka) async {
    String stavKonzumace = '';

    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((nacarkovanaPolozkaTx) async {
        Result macarkovanaPolozkaVysledek = await nacarkovanaPolozkaTx.execute(
            Sql.named(
                'UPDATE public.konzumace SET id_konzument = @id_konzument, id_carkujici = @id_carkujici, id_polozka = @id_polozka, kusu = @kusu, pevna_cena = @pevna_cena, poznamka = @poznamka WHERE id = @id;'),
            parameters: {
              //'datum_cas':
              //    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'id_konzument': konzument!.id,
              'id_carkujici': carkujici!.id,
              'id_polozka': polozka!.id,
              'kusu': kusy,
              'pevna_cena': cena,
              'poznamka': poznamka,
              'id': id,
            });
        stavKonzumace = (macarkovanaPolozkaVysledek.affectedRows > 0
            ? 'konzumace upravena'
            : 'chyba10');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavKonzumace;
  }

  Future<String> pridejKorekci(
      Polozka polozka, int rozdilKusu, String? poznamka) async {
    String stavKorekce = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((korekceTx) async {
        Result korekceVysledek = await korekceTx.execute(
            Sql.named(
                'INSERT INTO public.korekce(datum_cas, id_polozka, rozdil_kusu, id_zapsal, poznamka) VALUES (@datum_cas, @id_polozka, @rozdil_kusu, @id_zapsal, @poznamka)'),
            parameters: {
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'id_polozka': polozka.id,
              'rozdil_kusu': rozdilKusu,
              'id_zapsal': AktualniVedouci.vedouci?.id,
              'poznamka': poznamka,
            });
        stavKorekce =
            (korekceVysledek.affectedRows > 0 ? 'korekce pridana' : 'chyba11');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavKorekce;
  }

  Future<List<Korekce>> vratKorekce() async {
    List<Korekce> seznamKorekci = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((vratkyObaluTx) async {
        final seznamRaw = await vratkyObaluTx.execute(Sql.named(
            "SELECT k.id, k.datum_cas, k.id_polozka, CASE WHEN k.id_polozka = 1 THEN 'Prázdné lahve' WHEN k.id_polozka = 2 THEN 'Přepravky' ELSE p.nazev END AS nazev, k.rozdil_kusu, v.prezdivka, k.poznamka FROM public.korekce k INNER JOIN public.vedouci v ON k.id_zapsal = v.id LEFT JOIN public.polozky p ON k.id_polozka = p.id ORDER BY k.id DESC;"));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          DateTime datumAcas =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(radek[1].toString());
          int idPolozka = radek[2] as int;
          String nazevPolozka = radek[3] as String;
          int rozdilKusu = radek[4] as int;
          String zapsal = radek[5] as String;
          String poznamka = radek[6]?.toString() ?? '';
          seznamKorekci.add(Korekce(
              id: id,
              datumAcas: datumAcas,
              polozka: Polozka(id: idPolozka, nazev: nazevPolozka),
              kusu: rozdilKusu,
              zapsal: zapsal,
              poznamka: poznamka));
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return seznamKorekci;
  }
}
