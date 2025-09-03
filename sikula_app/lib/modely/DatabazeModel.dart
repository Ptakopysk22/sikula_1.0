import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Ucet.dart';

class DatabazeModel {
  Connection? pripojeni;

  Future<List<Ucet>> vratUcty() async {
    List<Ucet> ucty = [];
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((uctyTx) async {
        final seznamRaw = await uctyTx
            .execute(Sql.named('SELECT * FROM public.ucty ORDER BY id ASC'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          String nazev = radek[1] as String;
          ucty.add(Ucet(id: id, nazev: nazev));
        }
      });
    } catch (e) {
      // Zde možno poslat nějakou hlášku
    }
    return ucty;
  }

    Future<List<Kategorie>> vratSeznamKategorii() async {
    List<Kategorie> seznamKategorii = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((kategorieTx) async {
        final seznamRaw = await kategorieTx
            .execute(Sql.named('SELECT id, oznaceni FROM public.kategorie ORDER BY id ASC'));
        for (var radek in seznamRaw) {
          int id = radek[0] as int;
          String oznaceni = radek[1] as String;
          seznamKategorii.add(Kategorie(id: id, oznaceni: oznaceni));
        }
      });
    } catch (e) {
      // Zde možno poslat nějakou hlášku
    }
    return seznamKategorii;
  }




}
