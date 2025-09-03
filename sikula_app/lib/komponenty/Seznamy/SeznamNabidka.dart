import 'package:flutter/material.dart';

class SeznamNabidka<T> extends StatelessWidget {
  final List<T> seznam;
  final Function(T) titleFce;
  final Function(T) trailingFce;
  final Function(T) leadingFce;
  final Function(T) onTap;

  const SeznamNabidka({
    super.key,
    required this.seznam,
    required this.titleFce,
    required this.trailingFce,
    required this.leadingFce,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: seznam.length,
      itemBuilder: (context, index) {
        final prvek = seznam[index];
        return Card(
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 1.8),
            borderRadius: BorderRadius.circular(25),
          ),
          margin: const EdgeInsets.fromLTRB(5, 4, 5, 4),
          child: ListTile(
            onTap: () {
              onTap(prvek);
            },
            dense: true,
            contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            titleAlignment: ListTileTitleAlignment.center,
            leading: Text(
              leadingFce(prvek),
              style: const TextStyle(
                  fontFamily: 'Rye', fontSize: 23, fontWeight: FontWeight.bold),
            ),
            title: Text(
              titleFce(prvek),
              style: const TextStyle(
                  fontFamily: 'Smokum', fontSize: 30, fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              trailingFce(prvek),
              style: const TextStyle(
                  fontFamily: 'Rye', fontSize: 23, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}







