import 'package:flutter/material.dart';

class Tlacitko extends StatelessWidget {
  final Function()? poZmacknuti;
  final String text;

  const Tlacitko({super.key, required this.poZmacknuti, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: poZmacknuti,
      child: Container(
        padding: const EdgeInsets.all(18),
        margin: const EdgeInsets.symmetric(horizontal: 45),
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center, // Zarovná text na střed
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}
