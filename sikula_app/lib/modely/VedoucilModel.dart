import 'package:firebase_auth/firebase_auth.dart';
import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/BankovniUcet.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Vedouci.dart';

class VedoucilModel {
  //PripojeniDB pripojeniDB = PripojeniDB();
  Connection? pripojeni;

  Future<Vedouci> vratVedouciho(User uzivatel) async {
    late Vedouci aktualniVedouci;
    try {
      //pripojeni ??= await pripojeniDB.vytvorSpojeni();
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((funkceTx) async {
        final vedouciVyseldek = await funkceTx.execute(
            Sql.named(
                'SELECT v.id AS vedouci_id, v.prezdivka, v.email, v.funkce, v.bankovni_ucet, k.id AS konzument_id, k.cip, k.kredit, k.zkonzumovanych_kusu, k.nacarkovanych_kusu FROM public.vedouci v LEFT JOIN public.konzumenti k ON v.id = k.id_vedouci WHERE v.email = @email;'),
            parameters: {'email': uzivatel.email});
        if (vedouciVyseldek.affectedRows == 0) {
          aktualniVedouci = Vedouci(
              id: 1000, prezdivka: 'Žádná', email: 'Žádný', funkce: 'Žádná');
        } else {
          for (var radek in vedouciVyseldek) {
            int id = radek[0] as int;
            String prezdivka = radek[1] as String;
            String email = radek[2] as String;
            String funkce = radek[3] as String;
            String? bankovniUcet = radek[4] as String?;
            int? idKonzument = radek[5] as int?;
            String? cip = radek[6] as String?;
            double? kredit = double.tryParse((radek[7] ?? '') as String);
            int? zkonzumovanychKusu = radek[8] as int?;
            int? nacarkovanychKusu = radek[9] as int?;
            if (idKonzument == null) {
              aktualniVedouci = Vedouci(
                  id: id,
                  prezdivka: prezdivka,
                  email: email,
                  funkce: funkce,
                  bankovniUcet: vratBankovniUcetzTextu(bankovniUcet));
            } else {
              Konzument konzument = Konzument(
                  id: idKonzument,
                  prezdivka: prezdivka,
                  cip: cip,
                  kredit: kredit,
                  zkonzumovanychKusu: zkonzumovanychKusu,
                  nacarkovanychKusu: nacarkovanychKusu);
              aktualniVedouci = Vedouci(
                  id: id,
                  prezdivka: prezdivka,
                  email: email,
                  funkce: funkce,
                  bankovniUcet: vratBankovniUcetzTextu(bankovniUcet),
                  konzument: konzument);
            }
          }
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return aktualniVedouci;
  }

  Future<Vedouci> vratAktualnihoVedouciho(Vedouci vedouci) async {
    late Vedouci aktualniVedouci;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((funkceTx) async {
        final vedouciVyseldek = await funkceTx.execute(
            Sql.named(
                'SELECT v.id AS vedouci_id, v.prezdivka, v.email, v.funkce, v.bankovni_ucet, k.id AS konzument_id, k.cip, k.kredit, k.zkonzumovanych_kusu, k.nacarkovanych_kusu FROM public.vedouci v LEFT JOIN public.konzumenti k ON v.id = k.id_vedouci WHERE v.id = @id;'),
            parameters: {'id': vedouci.id});
        if (vedouciVyseldek.affectedRows == 0) {
          aktualniVedouci = Vedouci(
              id: 1000, prezdivka: 'Žádná', email: 'Žádný', funkce: 'Žádná');
        } else {
          for (var radek in vedouciVyseldek) {
            int id = radek[0] as int;
            String prezdivka = radek[1] as String;
            String email = radek[2] as String;
            String funkce = radek[3] as String;
            String? bankovniUcet = radek[4] as String?;
            int? idKonzument = radek[5] as int?;
            String? cip = radek[6] as String?;
            double? kredit = double.tryParse((radek[7] ?? '') as String);
            int? zkonzumovanychKusu = radek[8] as int?;
            int? nacarkovanychKusu = radek[9] as int?;
            if (idKonzument == null) {
              aktualniVedouci = Vedouci(
                  id: id,
                  prezdivka: prezdivka,
                  email: email,
                  funkce: funkce,
                  bankovniUcet: vratBankovniUcetzTextu(bankovniUcet));
            } else {
              Konzument konzument = Konzument(
                  id: idKonzument,
                  prezdivka: prezdivka,
                  cip: cip,
                  kredit: kredit,
                  zkonzumovanychKusu: zkonzumovanychKusu,
                  nacarkovanychKusu: nacarkovanychKusu);
              aktualniVedouci = Vedouci(
                  id: id,
                  prezdivka: prezdivka,
                  email: email,
                  funkce: funkce,
                  bankovniUcet: vratBankovniUcetzTextu(bankovniUcet),
                  konzument: konzument);
            }
          }
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return aktualniVedouci;
  }

  Future<Vedouci> vratVedoucihoDleKonzumenta(Konzument konzument) async {
    late Vedouci vedouci;
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((funkceTx) async {
        final vedouciVyseldek = await funkceTx.execute(
            Sql.named(
                'SELECT v.id AS vedouci_id, v.prezdivka, v.email, v.funkce, v.bankovni_ucet FROM public.vedouci v LEFT JOIN public.konzumenti k ON v.id = k.id_vedouci WHERE k.id = @id_konzument;'),
            parameters: {'id_konzument': konzument.id});
        for (var radek in vedouciVyseldek) {
          int id = radek[0] as int;
          String prezdivka = radek[1] as String;
          String email = radek[2] as String;
          String funkce = radek[3] as String;
          String? bankovniUcet = radek[4] as String?;
          vedouci = Vedouci(
              id: id,
              prezdivka: prezdivka,
              email: email,
              funkce: funkce,
              bankovniUcet: vratBankovniUcetzTextu(bankovniUcet),
              konzument: konzument);
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return vedouci;
  }

  Future<String> pridejVedouciho(
      String prezdivka, String email, String funkce) async {
    String stavNovyVedouci = '';
    //nebude potřeba vracet pokud nebudu ukládat do zařízení, ale vždy budu číst jen z datbáze
    //int novyVedouciID;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((novyVedouciTx) async {
        //nesmí existovat žádný vedoucí se stejnou přezdívkou ani se stejným emailem
        Result existujiciPrezdivkaVysledek = await novyVedouciTx.execute(
            Sql.named(
                'SELECT COUNT(*) FROM public.vedouci WHERE prezdivka = @prezdivka'),
            parameters: {'prezdivka': prezdivka});
        Result existujiciEmailVysledek = await novyVedouciTx.execute(
            Sql.named(
                'SELECT COUNT(*) FROM public.vedouci WHERE email = @email'),
            parameters: {'email': email});
        int pocetPrezdivka = existujiciPrezdivkaVysledek[0][0] as int;
        int pocetEmail = existujiciEmailVysledek[0][0] as int;

        if (pocetPrezdivka > 0 || pocetEmail > 0) {
          stavNovyVedouci = 'jiz existuje';
        } else {
          Result novyVedouciVysledek = await novyVedouciTx.execute(
              Sql.named(
                  'INSERT INTO public.vedouci(prezdivka, email, funkce) VALUES (@prezdivka, @email, @funkce) RETURNING id'),
              parameters: {
                'prezdivka': prezdivka,
                'email': email,
                'funkce': funkce
              });
          stavNovyVedouci = (novyVedouciVysledek.affectedRows > 0
              ? 'vedouci pridan'
              : 'chyba1');
          //novyVedouciID = novyVedouciVysledek[0][0] as int;
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavNovyVedouci;
  }

  Future<List<Vedouci>> vratSeznamVedoucich() async {
    List<Vedouci> seznamVedoucich = [];
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((seznamVedoucichTx) async {
        final seznamRaw = await seznamVedoucichTx.execute(Sql.named(
            'SELECT v.id, v.prezdivka, v.email, v.funkce, k.id FROM public.vedouci v LEFT JOIN public.konzumenti k ON v.id = k.id_vedouci ORDER BY v.id;'));
        for (var radek in seznamRaw) {
          //index označuje sloupec
          int id = radek[0] as int;
          String prezdivka = radek[1] as String;
          String email = radek[2] as String;
          String funkce = radek[3] as String;
          int? idKonzument = radek[4] as int?;
          seznamVedoucich.add(Vedouci(
              id: id,
              prezdivka: prezdivka,
              email: email,
              funkce: funkce,
              konzument: Konzument(id: idKonzument, prezdivka: prezdivka)));
        }
      });
    } catch (e) {
      // Zde možno poslat nějakou hlášku
    }
    return seznamVedoucich;
  }

  Future<String> upravVedouciho(
      int id, String prezdivka, String email, String funkce) async {
    String stavUpravenyVedouci = '';
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((novyVedouciTx) async {
        //nesmí existovat žádný vedoucí se stejnou přezdívkou ani se stejným emailem
        Result existujiciPrezdivkaVysledek = await novyVedouciTx.execute(
            Sql.named(
                'SELECT COUNT(*) FROM public.vedouci WHERE prezdivka = @prezdivka AND id <> @id'),
            parameters: {'prezdivka': prezdivka, 'id': id});
        Result existujiciEmailVysledek = await novyVedouciTx.execute(
            Sql.named(
                'SELECT COUNT(*) FROM public.vedouci WHERE email = @email AND id <> @id'),
            parameters: {'email': email, 'id': id});
        int pocetPrezdivka = existujiciPrezdivkaVysledek[0][0] as int;
        int pocetEmail = existujiciEmailVysledek[0][0] as int;

        if (pocetPrezdivka > 0 || pocetEmail > 0) {
          stavUpravenyVedouci = 'jiz existuje';
        } else {
          Result novyVedouciVysledek = await novyVedouciTx.execute(
              Sql.named(
                  'UPDATE public.vedouci SET prezdivka = @prezdivka, email = @email, funkce = @funkce WHERE id = @id'),
              parameters: {
                'id': id,
                'prezdivka': prezdivka,
                'email': email,
                'funkce': funkce
              });
          stavUpravenyVedouci = (novyVedouciVysledek.affectedRows > 0
              ? 'vedouci upraven'
              : 'chyba2');
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavUpravenyVedouci;
  }

  Future<BankovniUcet?> vratBankovniUcet(Vedouci? vedouci) async {
    BankovniUcet? bankovniUcet;
    String? bankovniUcetCely;
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((bankovniUcetTx) async {
        final bankovniUcetVysledeky = await bankovniUcetTx.execute(
            Sql.named(
                'SELECT v.bankovni_ucet FROM public.vedouci v WHERE v.id = @id;'),
            parameters: {'id': vedouci!.id});
        for (var radek in bankovniUcetVysledeky) {
          bankovniUcetCely = radek[0] as String?;
        }
        if (bankovniUcetCely == null) {
          bankovniUcet = null;
        } else {
          List<String> casti = bankovniUcetCely!.split('/');
          if (casti.length == 2) {
            String zakladniCast = casti[0];
            String kodBanky = casti[1];
            bankovniUcet =
                BankovniUcet(zakladniCast: zakladniCast, kodBanky: kodBanky);
          } else {
            bankovniUcet = null;
          }
        }
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return bankovniUcet;
  }

  Future<String> upravUcet(
      Vedouci vedouci, String zakladniCast, String kodBanky) async {
    String stavUctu = '';
    BankovniUcet bankovniUcet =
        BankovniUcet(zakladniCast: zakladniCast, kodBanky: kodBanky);
    try {
     pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((ucetTx) async {
        Result ucetVysledek = await ucetTx.execute(
            Sql.named(
                'UPDATE public.vedouci SET bankovni_ucet = @bankovni_ucet WHERE id = @id'),
            parameters: {
              'id': vedouci.id,
              'bankovni_ucet': bankovniUcet.toString(),
            });
        stavUctu = (ucetVysledek.affectedRows > 0 ? 'ucet upraven' : 'chyba12');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavUctu;
  }

  BankovniUcet? vratBankovniUcetzTextu(String? ucet) {
    if (ucet == null) {
      return null;
    }
    List<String> casti = ucet.split('/');
    if (casti.length != 2) {
      throw const FormatException("Neplatný formát účtu");
    }
    return BankovniUcet(
      zakladniCast: casti[0],
      kodBanky: casti[1],
    );
  }
}
