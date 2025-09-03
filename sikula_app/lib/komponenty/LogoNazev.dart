import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/komponenty/Tlacitko.dart';
import 'package:sikula/services/AuthService.dart';
import 'package:url_launcher/url_launcher.dart';

class LogoNazev extends StatelessWidget {
  final bool prihlasovaci;
  const LogoNazev({super.key, required this.prihlasovaci});

  void prihlasUzivatele(BuildContext context) async {
    await AuthService().prihlasPresGoogle();
    context.go('/domovska');
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.32), // Střed gradientu
          radius: 0.5, // Poloměr gradientu (od středu ke kraji)
          colors: [
            Color(0xFF0C6C4C),
            Color(0xFF0A2B1F),
          ],
          stops: [0.2, 0.85], // Pozice zastavení gradientu
        ),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 150),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 260),
            ],
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/napis.png', height: 80),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'verze 1.0',
            style: TextStyle(
                color: Color(0xFF0C6C4C),
                fontStyle: FontStyle.italic,
                fontSize: 20),
          ),
          const SizedBox(height: 30),
          prihlasovaci
              ? Tlacitko(
                  poZmacknuti: () => prihlasUzivatele(context),
                  text: 'Přihlásit',
                )
              : Container(),
          const Spacer(), // Přidání Spaceru, aby se další widgety tlačily dolů
          prihlasovaci
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Intrení systém pro potřeby ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _launchInBrowser(
                            Uri(scheme: 'https', host: 'www.bosan.cz'));
                      },
                      child: const Text('www.bosan.cz',
                          style: TextStyle(
                              color: Color(0xFF0C6C4C),
                              fontSize: 17,
                              letterSpacing: 0.5)),
                    )
                  ],
                )
              : Container(),
          const SizedBox(height: 20)
        ],
      ),
    );
  }
}
