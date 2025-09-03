import 'package:flutter/material.dart';

class SrdcovaLista extends StatelessWidget {
  final double? kreditVstup;

  const SrdcovaLista({super.key, required this.kreditVstup});

  @override
  Widget build(BuildContext context) {
    int kredit = kreditVstup?.toInt() ?? 0;
    int maxHearts = 6;
     int maxCredits = 200;
    int creditsPerHeart = (maxCredits / maxHearts).ceil();;
     int fullHearts = (kredit / creditsPerHeart).ceil().clamp(0, maxHearts);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(maxHearts, (index) {
        return Icon(
          index < fullHearts ? Icons.favorite : Icons.favorite_border,
          color: Colors.red[700],
          size: 45,
        );
      }),
    );
  }
}
