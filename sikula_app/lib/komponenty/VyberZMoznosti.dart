import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';

class VyberZMoznosti extends StatefulWidget {
  final SingleValueDropDownController moznostiContoller;
  final List<String?> moznosti;
  final String napoveda;
  final String chybovka;
  final Function(String?) onChanged; // Callback funkce

  const VyberZMoznosti(
      {super.key,
      required this.moznostiContoller,
      required this.moznosti,
      required this.napoveda,
      required this.chybovka,
      required this.onChanged});

  @override
  State<VyberZMoznosti> createState() => _VyberZMoznostiState();
}

class _VyberZMoznostiState extends State<VyberZMoznosti> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String?>(
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 23),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
      ),
     hint: Text(
        widget.napoveda,
        style: TextStyle(
          color: Colors.grey[650],
          fontWeight: FontWeight.bold,
          fontSize: 22,
          height: 1, // Upravená výška textu
        ),
      ),
      value: widget.moznostiContoller.dropDownValue?.value,
      items: widget.moznosti
          .map((item) => DropdownMenuItem<String?>(
                value: item,
                child: Text(
                  item!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.chybovka;
        }
        return null;
      },
      onChanged: widget.onChanged, // Volá callback funkci při změně hodnoty
      onSaved: (value) {
        selectedValue = value.toString();
      },
    );
  }
}
