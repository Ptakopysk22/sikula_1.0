import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'dart:async';

class NastaveniCipu extends StatefulWidget {
  const NastaveniCipu({super.key});

  @override
  State<NastaveniCipu> createState() => _NastaveniCipuState();
}

class _NastaveniCipuState extends State<NastaveniCipu> {
  late Zprava zprava;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    zprava = await _scanNfcAndWriteUri(context);
    if (!mounted) {
      setState(() {
        _isProcessing = false;
      });
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Čip nastaven') {
      Navigator.pop(context, true);
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<Zprava> _scanNfcAndWriteUri(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      final completer = Completer<bool>();

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            completer.complete(false);
            await NfcManager.instance
                .stopSession(errorMessage: 'Čip není zapisovatelný');
            return;
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createUri(Uri.parse('sikula://open')),
          ]);

          print('Zápis na čip');
          await ndef.write(message);
          await NfcManager.instance.stopSession();
          completer.complete(true);
        },
        onError: (NfcError error) async {
          print('Chyba při zápisu NFC: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při zápisu NFC: $error')),
          );
          await NfcManager.instance.stopSession();
          completer.complete(false);
        },
      );

      bool success = await completer.future;

      if (success) {
        print('Nastavení čipu bylo úspěšné');
        return Zprava(text: 'Čip nastaven');
      } else {
        print('Nastavení čipu selhalo');
        return Zprava(text: 'Nastavení čipu selhalo');
      }
    } catch (e) {
      print('Nastala chyba při zápisu NFC: $e');
      await NfcManager.instance.stopSession();
      return Zprava(text: 'Nastala chyba při zápisu NFC: $e');
    }
  }

  Future<bool> _onWillPop() async {
    await NfcManager.instance.stopSession();
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.brown[300],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 80,
            ),
            const Icon(
              FontAwesomeIcons.wifi,
              size: 100,
            ),
            const SizedBox(
              height: 40,
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    'Přilož čip',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'ještě jednou.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
