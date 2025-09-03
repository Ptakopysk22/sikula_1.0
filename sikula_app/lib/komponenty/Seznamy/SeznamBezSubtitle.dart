import 'package:flutter/material.dart';
import 'package:sikula/komponenty/Nacitac.dart';

class SeznamBezSubtitle<T> extends StatelessWidget {
  final Future<List<T>> futureSeznam;
  final Function(T) titleFce;
  final Function(T) trailingFce;
  final Function(T) leadingFce;
  final VoidCallback? onReturn; 

  const SeznamBezSubtitle({
    super.key,
    required this.futureSeznam,
    required this.titleFce,
    required this.trailingFce,
    required this.leadingFce,
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
                    dense: true,
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 0),
                    visualDensity:
                        const VisualDensity(horizontal: 0, vertical: -4),
                    titleAlignment: ListTileTitleAlignment.center,
                    leading: Text(
                      leadingFce(prvek),
                      style: const TextStyle(
                          fontFamily: 'Rye',
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                    title: Text(titleFce(prvek),
                        style: const TextStyle(
                          fontFamily: 'Smokum', fontSize: 30, fontWeight: FontWeight.bold),),
                    trailing: Text(
                      trailingFce(prvek),
                      style: const TextStyle(
                          fontFamily: 'Rye',
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    )),
              );
            },
          );
        }
      },
    );
  }
}
