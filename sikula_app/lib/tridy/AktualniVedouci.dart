import 'package:sikula/tridy/Vedouci.dart';

class AktualniVedouci {
  // Soukromý konstruktor
  AktualniVedouci._();

  // Statická instance Vedoucího
  static Vedouci? _vedouci;

  // Getter pro získání Vedoucího
  static Vedouci? get vedouci => _vedouci;

  // Setter pro nastavení Vedoucího
  static set vedouci(Vedouci? vedouci) {
    _vedouci = vedouci;
  }
}
