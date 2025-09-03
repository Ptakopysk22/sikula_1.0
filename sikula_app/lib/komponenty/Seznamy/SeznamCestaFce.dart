import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class SeznamCestaFce<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) subtitleFce;
  final Function(T) ikonaFce;
  final Function(T) leadingFce;
  final Function(T) cestaFce;
  final Future<Object?> Function(T) extraFce;
  final VoidCallback? onReturn;

  const SeznamCestaFce({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.subtitleFce,
    required this.ikonaFce,
    required this.leadingFce,
    this.onReturn,
    required this.cestaFce,
    required this.extraFce,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: futureSeznam,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Nacitac();
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final seznam = snapshot.data!;
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
                  onTap: () async {
                    final extra = await extraFce(prvek);
                    final result =
                        await context.push(cestaFce(prvek), extra: extra);
                    if (result == true && onReturn != null) {
                      onReturn!();
                    }
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                  visualDensity:
                      const VisualDensity(horizontal: 0, vertical: -4),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: Container(
                    width: 84, // Nastavení šířky
                    alignment: Alignment.centerRight, // Zarovnání obsahu doleva
                    child: Text(
                      leadingFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  title: Text(titleFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(subtitleFce(prvek),
                      style: const TextStyle(fontSize: 12)),
                  trailing: ikonaFce(prvek),
                ),
              );
            },
          );
        }
      },
    );
  }
}
