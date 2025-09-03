import 'package:flutter/material.dart';

class CiselnePole extends StatelessWidget {
  final TextEditingController cisloContoller;
  final String napoveda;
  final String chybovka;

  CiselnePole(
      {super.key,
      required this.cisloContoller,
      required this.napoveda,
      required this.chybovka});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      //cursorColor: Colors.black,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        hintText: napoveda,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
      controller: cisloContoller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return chybovka;
        }
        String adjustedValue = value.replaceAll(',', '.');
        final number = num.tryParse(adjustedValue);
        if (number == null) {
          return 'Zadej platné číslo';
        }
        return null;
      },
    );
  }
}
