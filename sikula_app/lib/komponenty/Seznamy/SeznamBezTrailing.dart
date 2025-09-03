/*import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class SeznamBezTrailing<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) subtitleFce;
  final Function(T) leadingFce;
  final String cesta;
  final VoidCallback? onReturn;

  const SeznamBezTrailing({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.subtitleFce,
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
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: Container(
                    width: 70, // Nastavení šířky
                    alignment: Alignment.centerRight, // Zarovnání obsahu doleva
                    child: Text(
                      leadingFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  title: Text(titleFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium),
                                subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    subtitleFce(prvek)[0],
                  ),
                  subtitleFce(prvek).length == 3
                      ? Text(
                          '${subtitleFce(prvek)[1].substring} <= ${subtitleFce(prvek)[2]}')
                      : Text('${subtitleFce(prvek)[1]}')
                ],
              ),
                ),
              );
            },
          );
        }
      },
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class SeznamBezTrailing<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) subtitleFce;
  final Function(T) leadingFce;
  final String cesta;
  final VoidCallback? onReturn;

  const SeznamBezTrailing({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.subtitleFce,
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
              final subtitles = subtitleFce(prvek);
              final limitedSubtitle1 = subtitles[1].substring(0, subtitles[1].length >= 4 ? 4 : subtitles[1].length);
              final limitedSubtitle2 =  subtitleFce(prvek).length == 3 ? subtitles[2].substring(0, subtitles[2].length >= 4 ? 4 : subtitles[2].length) : '';

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
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 15, 0),
                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                  titleAlignment: ListTileTitleAlignment.center,
                  leading: Container(
                    width: 70, // Nastavení šířky
                    alignment: Alignment.centerRight, // Zarovnání obsahu doprava
                    child: Text(
                      leadingFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  title: Text(titleFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        subtitles[0],
                      ),
                      subtitles.length == 3
                          ? Text(
                              '$limitedSubtitle1 <= $limitedSubtitle2')
                          : Text('${subtitles[1]}')
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
