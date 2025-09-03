import 'package:sikula/modely/DatabazeModel.dart';
import 'package:sikula/tridy/Kategorie.dart';
import 'package:sikula/tridy/Ucet.dart';

class DatabazeController {
  DatabazeModel databazeModel = DatabazeModel();

  Future<List<Ucet>> vratUcty() async {
    List<Ucet> ucty =
        await databazeModel.vratUcty();
    return ucty;
  }

    Future<List<Kategorie>> vratSeznamKategorii() async {
    List<Kategorie> seznamKategorii =
        await databazeModel.vratSeznamKategorii();
    return seznamKategorii;
  }


}
