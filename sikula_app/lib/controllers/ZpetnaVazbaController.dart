import 'package:sikula/modely/ZpetnaVazbaModel.dart';
import 'package:sikula/tridy/Vedouci.dart';

class ZpetnaVazbaController {
  ZpetnaVazbaModel zpetnaVazbaModel = ZpetnaVazbaModel();

  Future<String> pridejZpetnouVazbu(Vedouci vedouci, String komentar) async {
    String hlaska =
        await zpetnaVazbaModel.pridejZpetnouVazbu(vedouci, komentar);
    return hlaska;
  }
}
