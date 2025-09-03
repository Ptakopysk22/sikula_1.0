/*import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';

// ignore: must_be_immutable
class PridaniKonzumenta extends StatelessWidget {
  late final SingleValueDropDownController prezdivkaController;
  //zde nesmí být final!
  late String? prezdivka;
  late String cip;

  PridaniKonzumenta({super.key}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    prezdivka = null;
  }
  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  _pridejKonzumenta(BuildContext context) async {
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip);
    Zprava zprava = spravceZprav.nastavZpravu(stavKonzument);
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      //pouze ty, co ještě nejsou konzumenty
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Konzumenti'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  Zprava zprava;
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    zprava = await _pridejKonzumenta(context);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(zprava.text)));
                    if (zprava.text == 'Konzument přidán' ||
                        zprava.text == "Konzument upraven") {
                      context.pop(true);
                    }
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          VyberZMoznosti(
                              moznostiContoller: prezdivkaController,
                              moznosti: prezdivky,
                              napoveda: 'Vyber konzumenta',
                              chybovka: 'Vyber prezdivku konzumenta',
                              onChanged: (String? value) {
                                prezdivka = value;
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('a poté přilož nový čip.')
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}*/
/*
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

// ignore: must_be_immutable
class PridaniKonzumenta extends StatelessWidget {
  late final SingleValueDropDownController prezdivkaController;
  //zde nesmí být final!
  late String? prezdivka;
  late String? cip;

  PridaniKonzumenta({super.key}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    prezdivka = null;
    cip = null;
  }
  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    Zprava zprava = spravceZprav.nastavZpravu(stavKonzument);
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      //pouze ty, co ještě nejsou konzumenty
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  Future<void> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll();
      cip = nfcTag.id;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Zprava zprava = await _pridejKonzumenta(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(zprava.text)));
        if (zprava.text == 'Konzument přidán') {
          context.pop(true);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Konzumenti'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  if (prezdivka == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vyber prezdivku konzumenta')),
                    );
                  } else {
                    await _scanNfcAndAddKonzument(context);
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          VyberZMoznosti(
                              moznostiContoller: prezdivkaController,
                              moznosti: prezdivky,
                              napoveda: 'Vyber konzumenta',
                              chybovka: 'Vyber prezdivku konzumenta',
                              onChanged: (String? value) {
                                prezdivka = value;
                              }),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('A poté přilož nový čip.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}*/
/*
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class PridaniKonzumenta extends StatelessWidget {
  late final SingleValueDropDownController prezdivkaController;
  late String? prezdivka;
  late String? cip;

  PridaniKonzumenta({super.key}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    prezdivka = null;
    cip = null;
  }

  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    Zprava zprava = spravceZprav.nastavZpravu(stavKonzument);
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  Future<void> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      debugPrint('Spuštění NFC načítání...');
      var nfcTag = await FlutterNfcKit.poll();
      debugPrint('NFC čip načten: ${nfcTag.id}');
      cip = nfcTag.id;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        Zprava zprava = await _pridejKonzumenta(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(zprava.text)));
        if (zprava.text == 'Konzument přidán' ||
            zprava.text == "Konzument upraven") {
          context.pop(true);
        }
      }
    } catch (e) {
      debugPrint('Chyba při načítání NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
      debugPrint('NFC načítání ukončeno.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Konzumenti'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  if (prezdivka == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vyber prezdivku konzumenta')),
                    );
                  } else {
                    await _scanNfcAndAddKonzument(context);
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          VyberZMoznosti(
                            moznostiContoller: prezdivkaController,
                            moznosti: prezdivky,
                            napoveda: 'Vyber konzumenta',
                            chybovka: 'Vyber prezdivku konzumenta',
                            onChanged: (String? value) {
                              prezdivka = value;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('A poté přilož nový čip.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}*/
/*
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class PridaniKonzumenta extends StatelessWidget {
  late final SingleValueDropDownController prezdivkaController;
  late String? prezdivka;
  late String? cip;

  PridaniKonzumenta({super.key}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    prezdivka = null;
    cip = null;
  }

  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    Zprava zprava = spravceZprav.nastavZpravu(stavKonzument);
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  Future<void> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      debugPrint('Spuštění NFC načítání...');
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      debugPrint('NFC čip načten: ${nfcTag.id}');
      cip = nfcTag.id;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        debugPrint('Formulář validní, přidání konzumenta...');
        Zprava zprava = await _pridejKonzumenta(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(zprava.text)));
        if (zprava.text == 'Konzument přidán' ||
            zprava.text == "Konzument upraven") {
          debugPrint('Konzument úspěšně přidán.');
          context.pop(true);
        }
      } else {
        debugPrint('Formulář není validní.');
      }
    } catch (e) {
      debugPrint('Chyba při načítání NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
      debugPrint('NFC načítání ukončeno.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Konzumenti'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  if (prezdivka == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vyber prezdivku konzumenta')),
                    );
                  } else {
                    await _scanNfcAndAddKonzument(context);
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          VyberZMoznosti(
                            moznostiContoller: prezdivkaController,
                            moznosti: prezdivky,
                            napoveda: 'Vyber konzumenta',
                            chybovka: 'Vyber prezdivku konzumenta',
                            onChanged: (String? value) {
                              prezdivka = value;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('A poté přilož nový čip.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}*/
/*
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class PridaniKonzumenta extends StatelessWidget {
  late final SingleValueDropDownController prezdivkaController;
  late String? prezdivka;
  late String? cip;

  PridaniKonzumenta({super.key}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    prezdivka = null;
    cip = null;
  }

  final _formKey = GlobalKey<FormState>();

  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    debugPrint('Přidávání konzumenta s přezdívkou: $prezdivka a čipem: $cip');
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    Zprava zprava = spravceZprav.nastavZpravu(stavKonzument);
    debugPrint('Výsledek přidání konzumenta: ${zprava.text}');
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  Future<void> _scanNfcAndAddKonzument(BuildContext context) async {
    try {
      debugPrint('Spuštění NFC načítání...');
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      debugPrint('NFC čip načten: ${nfcTag.id}');
      cip = nfcTag.id;
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        debugPrint('Formulář validní, přidání konzumenta...');
        Zprava zprava = await _pridejKonzumenta(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(zprava.text)));
        if (zprava.text == 'Konzument přidán' ||
            zprava.text == "Konzument upraven") {
          debugPrint('Konzument úspěšně přidán.');
          context.pop(true);
        }
      } else {
        debugPrint('Formulář není validní.');
      }
    } catch (e) {
      debugPrint('Chyba při načítání NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nastala chyba při načítání NFC: $e')),
      );
    } finally {
      await FlutterNfcKit.finish();
      debugPrint('NFC načítání ukončeno.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: const Text('Konzumenti'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              floatingActionButton: FloatingActionButton(
                child: const Icon(Icons.arrow_forward_outlined),
                onPressed: () async {
                  if (prezdivka == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vyber prezdivku konzumenta')),
                    );
                  } else {
                    await _scanNfcAndAddKonzument(context);
                  }
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          VyberZMoznosti(
                            moznostiContoller: prezdivkaController,
                            moznosti: prezdivky,
                            napoveda: 'Vyber konzumenta',
                            chybovka: 'Vyber prezdivku konzumenta',
                            onChanged: (String? value) {
                              prezdivka = value;
                              debugPrint('Vybraná přezdívka: $prezdivka');
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text('A poté přilož nový čip.'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}*/

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/Tlacitko.dart';
import 'package:sikula/komponenty/VyberZMoznosti.dart';
import 'package:sikula/spravcove/SpravceZprav.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/Zprava.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

// ignore: must_be_immutable
class PridaniKonzumentaNeboZmenaCipu extends StatelessWidget {
  final Vedouci vedouci;
  late final SingleValueDropDownController prezdivkaController;
  late String? prezdivka;
  late String? cip;

  PridaniKonzumentaNeboZmenaCipu({super.key, required this.vedouci}) {
    prezdivkaController = SingleValueDropDownController(data: null);
    vedouci.id == 1000 ? prezdivka = null : prezdivka = vedouci.prezdivka;
    cip = null;
  }

  final _formKey = GlobalKey<FormState>();
  final SpravceZprav spravceZprav = SpravceZprav();
  KonzumentController konzumentController = KonzumentController();
  VedouciController vedouciController = VedouciController();
  List<Vedouci> sezanmVedoucich = [];

  void _pridejKonzumentaBezCipu(BuildContext context) async {
    cip = 'Bez čipu';
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Zprava zprava = await _pridejKonzumenta(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(zprava.text)));
      if (zprava.text == 'Konzument přidán') {
        context.pop(true);
      }
    }
  }

  Future<Zprava> _pridejKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument = await konzumentController.pridejKonzumenta(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  void _upravKonzumentaBezCipu(BuildContext context) async {
    cip = 'Bez čipu';
    Zprava zprava = await _upravCipKonzumenta(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(zprava.text)));
    if (zprava.text == 'Čip změněn') {
      context.pop(true);
    }
  }

  Future<Zprava> _upravCipKonzumenta(BuildContext context) async {
    Zprava zprava;
    String stavKonzument = await konzumentController.upravCip(
        _vratVedoucihoDlePrezdivky(prezdivka), cip!);
    if (stavKonzument.contains('patří')) {
      zprava = Zprava(text: stavKonzument);
    } else {
      zprava = spravceZprav.nastavZpravu(stavKonzument);
    }
    return zprava;
  }

  Future<List<String>> _vratSeznamVedoucich(BuildContext context) async {
    sezanmVedoucich = await vedouciController.vratSeznamVedoucich();
    List<String> prezdivky = [];
    for (var vedouci in sezanmVedoucich) {
      //pouze ty co ještě nejsou konzumenty
      if (vedouci.konzument!.id == null) {
        prezdivky.add(vedouci.prezdivka);
      }
    }
    return prezdivky;
  }

  Vedouci? _vratVedoucihoDlePrezdivky(String? prezdivka) {
    for (var vedouci in sezanmVedoucich) {
      if (vedouci.prezdivka == prezdivka) {
        return vedouci;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _vratSeznamVedoucich(context),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Nacitac();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Chyba při načítání dat: ${snapshot.error}'),
            );
          } else {
            List<String> prezdivky = snapshot.data ?? [];
            return Scaffold(
              appBar: AppBar(
                title: vedouci.id == 1000
                    ? const Text('Nový konzument')
                    : const Text('Změna čipu'),
                backgroundColor: Colors.brown[800],
              ),
              backgroundColor: Colors.brown[300],
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 25,
                          ),
                          vedouci.id == 1000
                              ? VyberZMoznosti(
                                  moznostiContoller: prezdivkaController,
                                  moznosti: prezdivky,
                                  napoveda: 'Vyber konzumenta',
                                  chybovka: 'Vyber prezdivku konzumenta',
                                  onChanged: (String? value) {
                                    prezdivka = value;
                                  },
                                )
                              : Column(
                                  children: [
                                    const Text('Přezdívka:'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      vedouci.konzument!.prezdivka,
                                      style: const TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                                                     const SizedBox(
                                      height: 10,
                                    ),
                                    const Text('Dosavadní číslo čipu:'),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text('${vedouci.konzument!.cip}',
                                        style: const TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold))
                                  ],
                                ),
                          const SizedBox(height: 130),
                          Tlacitko(
                              poZmacknuti: () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  final result = await context.push(
                                      '/domovska/carkovnikDomovskaHospodar/seznamKonzumentu/pridaniKonzumentaNeboZmenaCipu/nacteniCipu',
                                      extra: _vratVedoucihoDlePrezdivky(
                                          prezdivka));
                                  if (result == true) {
                                    context.pop(true);
                                  }
                                }
                              },
                              text: 'Konzument s čipem'),
                          const SizedBox(height: 50),
                          Tlacitko(
                              poZmacknuti: () {
                                vedouci.id == 1000
                                    ? _pridejKonzumentaBezCipu(context)
                                    : _upravKonzumentaBezCipu(context);
                              },
                              text: 'Konzument bez čipu'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
