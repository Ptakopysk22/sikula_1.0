import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class Seznam<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) subtitleFce;
  final Function(T) ikonaFce;
  final Function(T) leadingFce;
  final String cesta;
  final VoidCallback? onReturn; // Přidáme callback funkci

  const Seznam({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.subtitleFce,
    required this.ikonaFce,
    required this.leadingFce,
    required this.cesta,
    this.onReturn,
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
                    final result = await context.push(cesta, extra: prvek);
                    if (result == true && onReturn != null) {
                      onReturn!(); // Zavoláme callback funkci
                    }
                  },
                  dense: true,
                  contentPadding: const EdgeInsets.fromLTRB(15, 0, 25, 0),
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: Container(
                    width: 45, // Nastavení šířky
                    alignment: Alignment.centerRight, // Zarovnání obsahu doprava
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







