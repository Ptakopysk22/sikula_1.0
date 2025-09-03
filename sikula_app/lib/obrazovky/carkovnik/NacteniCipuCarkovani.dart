import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/KonzumentController.dart';
import 'package:sikula/tridy/Konzument.dart';

// ignore: must_be_immutable
class NacteniCipuCarkovani extends StatefulWidget {
  const NacteniCipuCarkovani({super.key});

  @override
  State<NacteniCipuCarkovani> createState() => _NacteniCipuCarkovaniState();
}

class _NacteniCipuCarkovaniState extends State<NacteniCipuCarkovani> {
  KonzumentController konzumentController = KonzumentController();
  late Konzument? konzument;
  late String? cip;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanNFCaOtveriCipoveCarkovani(context);
    });
  }

  void _otevriCipovecarkovani(BuildContext context) async {
    konzument = await konzumentController.vratKonzumentaDleCipu(cip);
    if (konzument != null) {
      final result = await context.push(
          '/domovska/carkovnikDomovskaKonzument/cipoveCarkovani',
          extra: konzument);
      if (result == true) {
        setState(() {
          context.pop(true);
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Čip není přiřazen')));
      context.pop();
    }
  }

  void _scanNFCaOtveriCipoveCarkovani(BuildContext context) async {
    try {
      var nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      cip = nfcTag.id;
      _otevriCipovecarkovani(context);
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
  }

  Future<bool> _onWillPop() async {
    context.push('/domovska/carkovnikDomovskaKOnzument');
    await FlutterNfcKit.finish();
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          backgroundColor: Colors.brown[300],
          body: Center(
            child: Column(
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
                  height: 60,
                ),
                Text(
                  'Přilož',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'amulet',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          )),
    );
  }
}
