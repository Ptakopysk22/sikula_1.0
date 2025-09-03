import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';
import 'package:sikula/modely/PripojeniDB.dart';
import 'package:sikula/tridy/Vedouci.dart';


class ZpetnaVazbaModel {
  Connection? pripojeni;

  Future<String> pridejZpetnouVazbu(
      Vedouci vedouci, String komentar) async {
    String stavZpetneVazby = '';
    try {
      pripojeni = await vytvorSpojeni();
      await pripojeni!.runTx((zpetnaVazbaTx) async {
        Result zpetnaVazbaVysledek = await zpetnaVazbaTx.execute(
            Sql.named(
                'INSERT INTO public.zpetna_vazba(datum_cas, id_vedouci, funkce, komentar) VALUES (@datum_cas, @id_vedouci, @funkce, @komentar)'),
            parameters: {
              'datum_cas':
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
              'id_vedouci': vedouci.id,
              'funkce': vedouci.funkce,
              'komentar': komentar,
            });
        stavZpetneVazby =
            (zpetnaVazbaVysledek.affectedRows > 0 ? 'zpetna vazba pridana' : 'chyba14');
      });
    } catch (e) {
      print('Něco se nepovedlo: $e');
    }
    return stavZpetneVazby;
  }


}
