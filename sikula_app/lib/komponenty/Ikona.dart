import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Ikona extends StatelessWidget {
  final String popisek;
  final IconData ikona;
  final String proklik;
  final Color barva;
  final dynamic extra;

  const Ikona(
      {super.key,
      required this.popisek,
      required this.ikona,
      required this.proklik,
      required this.barva,
      required this.extra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(proklik, extra: extra);
      },
      child: Container(
          width: 120,
          height: 120,
          child: Column(children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                border: Border.all(
                  color: barva,
                  width: 5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(child: Icon(ikona, size: 40)),
            ),
            Text(
              popisek,
              style: const TextStyle(fontSize: 13),
            )
          ])),
    );
  }
}
