/*import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();

  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late String? cip;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      final result = await context.push(
        '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu/nacteniCipu/nastaveniCipu',
      );
      if (result == true) {
        context.pop(true);
      }
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    print(stavKonzument);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument =
        await konzumentController.upravCip(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      if (widget.vedouci.konzument!.id == null) {
        zprava = await _pridejKonzumenta(context);
      } else {
        zprava = await _upravCipKonzumenta(context);
      }
      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      //zdržení čtení dalšího čipu!
      Future.delayed(const Duration(seconds: 7), () async {
        await FlutterNfcKit.finish();
      });
    }
    return Zprava(text: 'Chyba');
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await FlutterNfcKit.finish();
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
              Text(
                widget.vedouci.prezdivka,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'načten.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nyní přilož\n nový čip.',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              )
            ],
          )),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/obrazovky/carkovnik/NastaveniCipu.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late String? cip;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    if (_isProcessing) return; // Zajistěte, že funkce nebude spuštěna vícekrát současně
    setState(() {
      _isProcessing = true;
    });

    zprava = await _scanNfcAndAddKonzument(context);
    if (!mounted) {
      _isProcessing = false;
      return; // kontrola, zda je widget stále naživu
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NastaveniCipu()),
      );
      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    print(stavKonzument);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument =
        await konzumentController.upravCip(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      if (widget.vedouci.konzument!.id == null) {
        zprava = await _pridejKonzumenta(context);
      } else {
        zprava = await _upravCipKonzumenta(context);
      }
      return zprava;
    } catch (e) {
      if (!mounted) return Zprava(text: 'Chyba');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      if (mounted) {
        //zdržení čtení dalšího čipu!
        Future.delayed(const Duration(seconds: 7), () async {
          await FlutterNfcKit.finish();
        });
      }
    }
    return Zprava(text: 'Chyba');
  }

  Future<bool> _onWillPop() async {
    if (mounted) {
      context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
      await FlutterNfcKit.finish();
    }
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
              Text(
                widget.vedouci.prezdivka,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'načten.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nyní přilož\n nový čip.',
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              )
            ],
          )),
    );
  }
}



















/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:ndef/ndef.dart' as ndef;

class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late String? cip;
  bool prvniNacteni = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      setState(() {
        prvniNacteni = false; // Změníme text na "Přilož čip ještě jednou."
      });
    } else {
      Navigator.pop(context, true); // navigovat někam jinam!
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    print(stavKonzument);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument = await konzumentController.upravCip(
        widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;

      if (prvniNacteni) {
        if (widget.vedouci.konzument!.id == null) {
          zprava = await _pridejKonzumenta(context);
        } else {
          zprava = await _upravCipKonzumenta(context);
        }
      } else {
        // Zapisování dat na čip při druhém načtení
        await FlutterNfcKit.writeNDEFRecords([new ndef.UriRecord.fromUriString('https://github.com/nfcim/flutter_nfc_kit')]);
        var ndefWriteResult = await FlutterNfcKit.transceive('sikula://open');
        print("NDEF Write Result: $ndefWriteResult");
        zprava = Zprava(text: 'Text zapsán na čip');
        Navigator.pop(context, true);
      }

      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání nebo zápisu NFC: $e')),
      );
    } finally {
      // Zdržení čtení dalšího čipu!
      Future.delayed(const Duration(seconds: 7), () async {
        await FlutterNfcKit.finish();
      });
    }
    return Zprava(text: 'Chyba');
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await FlutterNfcKit.finish();
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
            Text(
              widget.vedouci.prezdivka,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'načten.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prvniNacteni
                      ? 'Nyní přilož\n nový čip.'
                      : 'Přilož čip\n ještě jednou.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late String? cip;
  bool prvniNacteni = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    zprava = 
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      setState(() {
        prvniNacteni = false; // Změníme text na "Přilož čip ještě jednou."
      });
    } else {
      Navigator.pop(context, true); // navigovat někam jinam!
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    print(stavKonzument);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument = await konzumentController.upravCip(
        widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          cip = tag.data['id']?.toString();

          if (prvniNacteni) {
            if (widget.vedouci.konzument!.id == null) {
              zprava = await _pridejKonzumenta(context);
            } else {
              zprava = await _upravCipKonzumenta(context);
            }
          } else {
            var ndef = Ndef.from(tag);
            if (ndef == null || !ndef.isWritable) {
              throw Exception('Čip není zapisovatelný');
            }

            NdefMessage message = NdefMessage([
              NdefRecord.createUri(Uri.parse('sikula://open')),
            ]);

            await ndef.write(message);
            print("NDEF Write Result: success");
            zprava = Zprava(text: 'Text zapsán na čip');
            Navigator.pop(context, true);
          }

          await NfcManager.instance.stopSession();
        },
        onError: (NfcError error) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při načítání nebo zápisu NFC: $error')),
          );
          await NfcManager.instance.stopSession();
        },
      );

      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání nebo zápisu NFC: $e')),
      );
      return Zprava(text: 'Chyba');
    }
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await NfcManager.instance.stopSession();
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
            Text(
              widget.vedouci.prezdivka,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              prvniNacteni ? 'načten.' : 'Přilož čip ještě jednou.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prvniNacteni
                      ? 'Nyní přilož\n nový čip.'
                      : 'Přilož čip ještě jednou.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
/*
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late Zprava zprava2;
  late String? cip;
  bool prvniNacteni = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    setState(() {
      prvniNacteni = false;
    });
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument =
        await konzumentController.upravCip(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }
/*
  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          cip = tag.data['id']?.toString();

          if (widget.vedouci.konzument!.id == null) {
            zprava = await _pridejKonzumenta(context);
          } else {
            zprava = await _upravCipKonzumenta(context);
          }

          await NfcManager.instance.stopSession();
        },
        onError: (NfcError error) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při načítání NFC: $error')),
          );
          await NfcManager.instance.stopSession();
        },
      );

      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
      return Zprava(text: 'Chyba');
    }
  }*/

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      if (widget.vedouci.konzument!.id == null) {
        zprava = await _pridejKonzumenta(context);
      } else {
        zprava = await _upravCipKonzumenta(context);
      }
      zprava2 = await _scanNfcAndWriteUri(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(zprava2.text)));
      if (zprava2.text == 'Čip nastaven') {
        Navigator.pop(context, true); // navigovat někam jinam!
      }
      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      //zdržení čtení dalšího čipu!
      Future.delayed(const Duration(seconds: 3), () async {
        await FlutterNfcKit.finish();
      });
    }
    return Zprava(text: 'Chyba');
  }

  Future<Zprava> _scanNfcAndWriteUri(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw Exception('Čip není zapisovatelný');
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createUri(Uri.parse('sikula://open')),
          ]);

          await ndef.write(message);
          zprava2 = Zprava(text: 'Čip nastaven');
          Future.delayed(const Duration(seconds: 3), () async {
            await FlutterNfcKit.finish();
          });

          await NfcManager.instance.stopSession();
        },
        onError: (NfcError error) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při zápisu NFC: $error')),
          );
          await NfcManager.instance.stopSession();
        },
      );

      return zprava;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při zápisu NFC: $e')),
      );
      return Zprava(text: 'Chyba');
    }
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await NfcManager.instance.stopSession();
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
            Text(
              widget.vedouci.prezdivka,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'načten.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prvniNacteni
                      ? 'Nyní přilož\n nový čip.'
                      : 'Přilož čip\n ještě jednou.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
/*

//funguje jen první přiložení
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late Zprava zprava2;
  late String? cip;
  bool prvniNacteni = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      setState(() {
        prvniNacteni = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Přilož čip ještě jednou pro zápis URI')),
      );

      zprava2 = await _scanNfcAndWriteUri(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(zprava2.text)));
      if (zprava2.text == 'Čip nastaven') {
        Navigator.pop(context, true);
      }
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      return Zprava(text: stavKonzument);
    } else {
      return spravceZprav.nastavZpravu(stavKonzument);
    }
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.upravCip(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      return Zprava(text: stavKonzument);
    } else {
      return spravceZprav.nastavZpravu(stavKonzument);
    }
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      if (widget.vedouci.konzument!.id == null) {
        return await _pridejKonzumenta(context);
      } else {
        return await _upravCipKonzumenta(context);
      }
    } catch (e) {
      return Zprava(text: 'Nastala chyba při načítání NFC: $e');
    } finally {
      Future.delayed(const Duration(seconds: 3), () async {
        await FlutterNfcKit.finish();
      });
    }
  }

  Future<Zprava> _scanNfcAndWriteUri(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw Exception('Čip není zapisovatelný');
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createUri(Uri.parse('sikula://open')),
          ]);

          await ndef.write(message);
          await NfcManager.instance.stopSession();
        },
        onError: (NfcError error) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při zápisu NFC: $error')),
          );
          await NfcManager.instance.stopSession();
        },
      );

      return Zprava(text: 'Čip nastaven');
    } catch (e) {
      return Zprava(text: 'Nastala chyba při zápisu NFC: $e');
    }
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await NfcManager.instance.stopSession();
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
            Text(
              widget.vedouci.prezdivka,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'načten.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prvniNacteni
                      ? 'Nyní přilož\n nový čip.'
                      : 'Přilož čip\n ještě jednou.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/
/*

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

class NacteniCipu extends StatefulWidget {
  final Vedouci vedouci;
  const NacteniCipu({super.key, required this.vedouci});

  @override
  State<NacteniCipu> createState() => _NacteniCipuState();
}

class _NacteniCipuState extends State<NacteniCipu> {
  KonzumentController konzumentController = KonzumentController();
  SpravceZprav spravceZprav = SpravceZprav();
  late Zprava zprava;
  late String? cip;
  bool prvniNacteni = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hlavniFce();
    });
  }

  _hlavniFce() async {
    zprava = await _scanNfcAndAddKonzument(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Konzument přidán' || zprava.text == 'Čip změněn') {
      setState(() {
        prvniNacteni = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Přilož čip ještě jednou pro zápis URI')),
      );

      Zprava zprava2 = await _scanNfcAndWriteUri(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(zprava2.text)));
      if (zprava2.text == 'Čip nastaven') {
        Navigator.pop(context, true);
      }
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.pridejKonzumenta(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      return Zprava(text: stavKonzument);
    } else {
      return spravceZprav.nastavZpravu(stavKonzument);
    }
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    String stavKonzument =
        await konzumentController.upravCip(widget.vedouci, cip!);
    if (stavKonzument.contains('patří')) {
      return Zprava(text: stavKonzument);
    } else {
      return spravceZprav.nastavZpravu(stavKonzument);
    }
  }

  Future<Zprava> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      if (widget.vedouci.konzument!.id == null) {
        return await _pridejKonzumenta(context);
      } else {
        return await _upravCipKonzumenta(context);
      }
    } catch (e) {
      return Zprava(text: 'Nastala chyba při načítání NFC: $e');
    } finally {
      Future.delayed(const Duration(seconds: 3), () async {
        await FlutterNfcKit.finish();
      });
    }
  }

  Future<Zprava> _scanNfcAndWriteUri(BuildContext context) async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        return Zprava(text: 'NFC není k dispozici');
      }

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var ndef = Ndef.from(tag);
          if (ndef == null || !ndef.isWritable) {
            throw Exception('Čip není zapisovatelný');
          }

          NdefMessage message = NdefMessage([
            NdefRecord.createUri(Uri.parse('sikula://open')),
          ]);

          await ndef.write(message);
          await NfcManager.instance.stopSession();
        },
        onError: (NfcError error) async {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Nastala chyba při zápisu NFC: $error')),
          );
          await NfcManager.instance.stopSession();
        },
      );

      return Zprava(text: 'Čip nastaven');
    } catch (e) {
      return Zprava(text: 'Nastala chyba při zápisu NFC: $e');
    }
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaHospodar/seznamKonzumentu');
    await NfcManager.instance.stopSession();
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
            Text(
              widget.vedouci.prezdivka,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'načten.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  prvniNacteni
                      ? 'Nyní přilož\n nový čip.'
                      : 'Přilož čip\n ještě jednou.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}*/

