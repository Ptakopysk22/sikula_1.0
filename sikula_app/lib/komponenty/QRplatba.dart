import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sikula/tridy/BankovniUcet.dart';

class QRplatba extends StatelessWidget {
  final BankovniUcet? bankovniUcet;
  final double? castka;
  final String zprava;
  final String mena;

  const QRplatba({super.key, 
    required this.bankovniUcet,
    required this.castka,
    required this.zprava,
    this.mena = 'CZK',
  });

  String generateIBAN(String accountNumber, String bankCode) {
    // CZ má IBAN kód CZ
    String countryCode = 'CZ';
    // Kód banky musí mít 4 číslice
    String bankCodePadded = bankCode.padLeft(4, '0');
    // Číslo účtu musí mít 16 číslic (včetně předčíslí)
    String accountNumberPadded = accountNumber.padLeft(16, '0');
    // Sestavení BBAN
    String bban = '$bankCodePadded$accountNumberPadded';
    // Sestavení řetězce pro výpočet kontrolních číslic
    String checkString = '${bban}123500';
    // Převedení na číslo
    BigInt checkInt = BigInt.parse(checkString);
    // Výpočet kontrolních číslic
    BigInt mod97 = BigInt.from(97);
    BigInt checkDigits = BigInt.from(98) - (checkInt % mod97);
    // IBAN
    String iban = '$countryCode${checkDigits.toString().padLeft(2, '0')}$bban';
    return iban;
  }

  @override
  Widget build(BuildContext context) {
    String IBANucet = generateIBAN(bankovniUcet!.zakladniCast, bankovniUcet!.kodBanky);
    final String qrData =
        'SPD*1.0*ACC:$IBANucet*AM:${castka!.toStringAsFixed(2)}*CC:$mena*MSG:$zprava';

    return QrImageView(
      data: qrData,
      version: QrVersions.auto,
      size: 320,
      gapless: false,
    );
  }
}
