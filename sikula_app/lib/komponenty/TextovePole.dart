import 'package:flutter/material.dart';

class TextovePole extends StatelessWidget {
  final TextEditingController textController;
  final String napoveda;
  final String? chybovka;
  final bool isRequired;

  const TextovePole(
      {super.key,
      required this.textController,
      required this.napoveda,
      required this.chybovka,
      this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      controller: textController,
      maxLines: null,
      minLines: 1,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return chybovka;
        }
        return null;
      },
    );
  }
}
