import 'package:flutter/material.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/komponenty/QRplatba.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Zaloha.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class QRplatbaZalohy extends StatelessWidget {
  final Zaloha zobrazovanaZaloha;
  QRplatbaZalohy({super.key, required this.zobrazovanaZaloha});
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();

  _pridejZalohu(BuildContext context) async {
    String stavZalohy = await konzumentController.pridejZalohu(
        zobrazovanaZaloha.konzument!,
        zobrazovanaZaloha.castka,
        zobrazovanaZaloha.ucet,
        zobrazovanaZaloha.poznamka);
    Zprava zprava = spravceZprav.nastavZpravu(stavZalohy);
    return zprava;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR záloha'),
        backgroundColor: Colors.brown[800],
      ),
      backgroundColor: Colors.brown[300],
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward_outlined),
        onPressed: () async {
          Zprava zprava;
          zprava = await _pridejZalohu(context);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(zprava.text)));
          if (zprava.text == 'Záloha přidána') {
            Navigator.pop(context, true); //navigovat někam jinam!
          }
        },
      ),
      body: Center(
          child: AktualniVedouci.vedouci!.bankovniUcet != null &&
                  zobrazovanaZaloha.ucet!.nazev == "Karta"
              ? QRplatba(
                  bankovniUcet: AktualniVedouci.vedouci!.bankovniUcet,
                  castka: zobrazovanaZaloha.castka,
                  zprava:
                      'Nabití kreditu - ${zobrazovanaZaloha.konzument!.prezdivka}')
              : zobrazovanaZaloha.ucet!.nazev == "Hotovost"
                  ? const Column(
                      children: [
                        SizedBox(
                          height: 100,
                        ),
                        Text('K platbě za hotové'),
                        Text('nelze vytvořit'),
                        Text('QR kód')
                      ],
                    )
                  :  const Column(children: [
                      SizedBox(
                        height: 100,
                      ),
                      Text('Chybí hospodářův'),
                      Text('bankovní účet'),
                    ])),
    );
  }
}
