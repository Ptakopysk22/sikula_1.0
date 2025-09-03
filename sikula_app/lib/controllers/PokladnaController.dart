import 'package:sikula/modely/PokladnaModel.dart';
import 'package:sikula/tridy/PokladniZaznam.dart';

class PokladnaController {
  PokladnaModel pokladnaModel = PokladnaModel();

  Future<List<PokladniZaznam>> vratSeznamZaznamu() async {
    List<PokladniZaznam> seznamZaznamu =
        await pokladnaModel.vratSeznamZaznamu();
    return seznamZaznamu;
  }

  Future<String> vratFinancniRezervu() async {
    String financniRezerva = await pokladnaModel.vratFinancniRezervu();
    return financniRezerva;
  }
}
