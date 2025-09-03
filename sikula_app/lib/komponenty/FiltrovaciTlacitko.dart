import 'package:flutter/material.dart';

class FiltrovaciTlacitko extends StatelessWidget {
  final String text;
  final bool jeZmacknute;
  final VoidCallback onPressed;

  const FiltrovaciTlacitko(
      {super.key, required this.text, required this.jeZmacknute, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
          backgroundColor: jeZmacknute
              ? MaterialStateProperty.all<Color>(Colors.green)
              : MaterialStateProperty.all<Color>(Colors.grey.shade700),
          minimumSize: MaterialStateProperty.all<Size>(
              const Size(175, 40)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: const BorderSide(color: Colors.black, width: 0.5),
          ))),
      child: Text(text,
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 23,
              letterSpacing: 3)),
    );
  }
}
