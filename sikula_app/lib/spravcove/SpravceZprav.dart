import 'package:sikula/tridy/Zprava.dart';

class SpravceZprav {
  late Zprava _zprava;
  late String _text;
  late String hlaska;

  nastavZpravu(hlaska) {
    if (hlaska.toString().contains("vedouci pridan")) {
      _text = 'Vedoucí přidán';
    } else if (hlaska.toString().contains("chyba1")) {
      _text = 'Chyba 1';
    } else if (hlaska.toString().contains("jiz existuje")) {
      _text =
          'Vedoucí se shodnnou přezdívkou nebo se shodným emailem již existuje';
    } else if (hlaska.toString().contains("chyba2")) {
      _text = 'Chyba 2';
    } else if (hlaska.toString().contains("vedouci upraven")) {
      _text = 'Vedoucí upraven';
    } else if (hlaska.toString().contains("polozka pridana")) {
      _text = 'Položka přidána';
    } else if (hlaska.toString().contains("chyba3")) {
      _text = 'Chyba 3';
    } else if (hlaska.toString().contains("polozka upravena")) {
      _text = 'Položka upravena';
    } else if (hlaska.toString().contains("chyba4")) {
      _text = 'Chyba 4';
    } else if (hlaska.toString().contains("zaloha pridana")) {
      _text = 'Záloha přidána';
    } else if (hlaska.toString().contains("chyba5")) {
      _text = 'Chyba 5';
    } else if (hlaska.toString().contains("polozka nacarkovana")) {
      _text = 'Položka načárkována';
    } else if (hlaska.toString().contains("chyba6")) {
      _text = 'Chyba 6';
    } else if (hlaska.toString().contains("obal pridana")) {
      _text = 'Obaly vráceny';
    } else if (hlaska.toString().contains("chyba8")) {
      _text = 'Chyba 8';
    } else if (hlaska.toString().contains("obal upraven")) {
      _text = 'Vratka obalu upravena';
    } else if (hlaska.toString().contains("chyba9")) {
      _text = 'Chyba 9';
    } else if (hlaska.toString().contains("konzumace upravena")) {
      _text = 'Konzumace upravena';
    } else if (hlaska.toString().contains("chyba10")) {
      _text = 'Chyba 10';
    } else if (hlaska.toString().contains("korekce pridana")) {
      _text = 'Korekce přidána';
    } else if (hlaska.toString().contains("chyba11")) {
      _text = 'Chyba 11';
    } else if (hlaska.toString().contains("zaloha upravena")) {
      _text = 'Záloha upravena';
    } else if (hlaska.toString().contains("chyba12")) {
      _text = 'Chyba 12';
    } else if (hlaska.toString().contains("ucet upraven")) {
      _text = 'Účet upraven';
    } else if (hlaska.toString().contains("chyba13")) {
      _text = 'Chyba 13';
    } else if (hlaska.toString().contains("zpetna vazba pridana")) {
      _text = 'Děkuji za zpětnou vazbu';
    } else if (hlaska.toString().contains("chyba14")) {
      _text = 'Chyba 14';
    } else if (hlaska.toString().contains("konzument pridan")) {
      _text = 'Konzument přidán';
    } else if (hlaska.toString().contains("chyba15")) {
      _text = 'Chyba 15';
    } else if (hlaska.toString().contains("cip upraven")) {
      _text = 'Čip změněn';
    } else if (hlaska.toString().contains("chyba16")) {
      _text = 'Chyba 16';
    } else {
      _text = 'CHYBA';
    }
    _zprava = Zprava(text: _text);
    return _zprava;
  }
}
