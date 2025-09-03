import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class SeznamSwipe<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) subtitleFce;
  final Function(T) trailingFce;
  final String cesta;
  final String cestaPravySwipe;
  final String cestaLevySwipe;
  final VoidCallback? onReturn;

  const SeznamSwipe({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.subtitleFce,
    required this.trailingFce,
    required this.cesta,
    this.onReturn,
    required this.cestaPravySwipe,
    required this.cestaLevySwipe,
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
              final prvekS = prvek.toString();
              return Dismissible(
                key: Key(prvekS),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    final result =
                        await context.push(cestaPravySwipe, extra: prvek);
                    if (result == true && onReturn != null) {
                      onReturn!();
                    }
                  } else if (direction == DismissDirection.endToStart) {
                    final result =
                        await context.push(cestaLevySwipe, extra: prvek);
                    if (result == true && onReturn != null) {
                      onReturn!();
                    }
                  }
                  return null;
                },
                child: Card(
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
                        onReturn!();
                      }
                    },
                    dense: true,
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text(
                      titleFce(prvek),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      subtitleFce(prvek),
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Text(
                      trailingFce(prvek),
                      style: TextStyle(
                          fontSize: 22,
                          color: trailingFce(prvek).contains('-')
                              ? Colors.red[700]
                              : Colors.grey[750]),
                    ),
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
