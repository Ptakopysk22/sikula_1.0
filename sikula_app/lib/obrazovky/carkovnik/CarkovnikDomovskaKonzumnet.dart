import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/komponenty/Nacitac.dart';
import 'package:sikula/komponenty/Radek.dart';
import 'package:sikula/komponenty/SrdcovaLista.dart';
import 'package:sikula/tridy/AktualniVedouci.dart';
import 'package:sikula/tridy/Vedouci.dart';

//nestačilo by tady pracovat jen s konzumentem! zbytečné načítat věci o vedoucím? né není, je potřba vědět co je za funkci na táboře - vyřešeno

class CarkovnikDomovskaKonzument extends StatefulWidget {
  final bool? prichodCipem;
  const CarkovnikDomovskaKonzument({super.key, required this.prichodCipem});

  @override
  State<CarkovnikDomovskaKonzument> createState() =>
      _CarkovnikDomovskaKonzumentState();
}

class _CarkovnikDomovskaKonzumentState
    extends State<CarkovnikDomovskaKonzument> {
  VedouciController vedouciController = VedouciController();
  Vedouci? zobrazovanyVedouci;

  @override
  void initState() {
    super.initState();
    if (widget.prichodCipem != null && widget.prichodCipem == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jdiNaCarkovani();
      });
    }
  }

  _jdiNaCarkovani() async {
    final result = await context.push(
        '/domovska/carkovnikDomovskaKonzument/nacteniCipuCarkovani',
        extra: AktualniVedouci.vedouci!.konzument);
    if (result == true) {
      setState(() {
        zobrazovanyVedouci = AktualniVedouci.vedouci;
      });
    }
  }

  Future<Vedouci?> _nactiVedouciho() async {
    return await vedouciController
        .vratAktualnihoVedouciho(AktualniVedouci.vedouci!);
  }

  Future<bool> _onWillPop() async {
    context.go('/domovska');
    return false; // zabrání defaultnímu chování zpět
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${AktualniVedouci.vedouci?.prezdivka}',
                    style: const TextStyle(fontFamily: 'Smokum', fontSize: 40))
              ],
            ),
            actions: [
              AktualniVedouci.vedouci?.funkce == 'Hospodář' ||
                      AktualniVedouci.vedouci?.funkce == 'Hlavas'
                  ? IconButton(
                      onPressed: () => AktualniVedouci.vedouci?.funkce ==
                              'Hospodář'
                          ? context.go('/domovska/carkovnikDomovskaHospodar')
                          : context.go(
                              '/domovska/carkovnikDomovskaKonzument/seznamKonzumaciHlavas'),
                      icon: Icon(
                        AktualniVedouci.vedouci?.funkce == 'Hospodář'
                            ? Icons.swap_horiz
                            : Icons.menu,
                        color: Colors.white,
                        size: 33,
                      ),
                    )
                  : Container(),
            ],
            backgroundColor: Colors.brown[800],
          ),
          backgroundColor: Colors.brown[300],
          body: FutureBuilder<Vedouci?>(
            future: _nactiVedouciho(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Nacitac();
              } else if (snapshot.hasError) {
                return const Center(
                    child: Text('Došlo k chybě při načítání dat'));
              } else {
                zobrazovanyVedouci = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
                  child: zobrazovanyVedouci!.konzument == null
                      ? const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                              SizedBox(
                                height: 150,
                              ),
                              Radek(text: 'Nejsi veden'),
                              Radek(text: 'jako konzument.'),
                              Radek(text: 'Dojdi si za'),
                              Radek(text: 'hospodářem.')
                            ])
                      : Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context.go(
                                        '/domovska/carkovnikDomovskaKonzument/seznamStrelcu');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: Colors.brown[800]!,
                                          width: 3.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color:
                                            const Color.fromARGB(255, 135, 111, 102)),
                                    child: const Text(
                                      'Střelci',
                                      style: TextStyle(
                                          fontFamily: 'Smokum',
                                          fontSize: 28,
                                          letterSpacing: 5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.go(
                                        '/domovska/carkovnikDomovskaKonzument/seznamDobijecu');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                          color: Colors.brown[800]!,
                                          width: 3.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        color:
                                            const Color.fromARGB(255, 135, 111, 102)),
                                    child: const Text('Dobíječi',
                                        style: TextStyle(
                                          fontFamily: 'Smokum',
                                          fontSize: 28,
                                          letterSpacing: 5,
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (zobrazovanyVedouci!
                                                      .konzument!.kredit! <
                                                  33 ||
                                              zobrazovanyVedouci!
                                                      .konzument!.kredit ==
                                                  null)
                                            const Icon(
                                              FontAwesomeIcons.skullCrossbones,
                                              size: 55,
                                            ),
                                          Column(
                                            children: [
                                              const Text(' Životy ',
                                                  style: TextStyle(
                                                      fontFamily: 'Smokum',
                                                      fontSize: 40)),
                                              Text(
                                                  '${zobrazovanyVedouci!.konzument!.kredit}',
                                                  style: TextStyle(
                                                      fontFamily: 'Rye',
                                                      fontSize: 18,
                                                      color:
                                                          Colors.red.shade900)),
                                            ],
                                          ),
                                          if (zobrazovanyVedouci!
                                                      .konzument!.kredit! <
                                                  33 ||
                                              zobrazovanyVedouci!
                                                      .konzument!.kredit ==
                                                  null)
                                            const Icon(
                                                FontAwesomeIcons
                                                    .skullCrossbones,
                                                size: 55),
                                        ],
                                      ),
                                      SrdcovaLista(
                                          kreditVstup: zobrazovanyVedouci!
                                              .konzument!.kredit),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Zásahů',
                                          style: TextStyle(
                                              fontFamily: 'Smokum',
                                              fontSize: 40)),
                                      Center(
                                        child: GestureDetector(
                                          onTap: _jdiNaCarkovani,
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                'assets/zamerovac.png',
                                                width: 200,
                                                height: 200,
                                              ),
                                              Positioned.fill(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${zobrazovanyVedouci!.konzument!.zkonzumovanychKusu}',
                                                    style: const TextStyle(
                                                        fontSize: 40,
                                                        fontFamily: 'Rye'),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Dobíječ',
                                          style: TextStyle(
                                              fontFamily: 'Smokum',
                                              fontSize: 40)),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Image.asset(
                                            'assets/nabojnice.png',
                                            width: 60,
                                            height: 60,
                                          ),
                                          Image.asset(
                                            'assets/nabojnice.png',
                                            width: 60,
                                            height: 60,
                                          ),
                                          Text(
                                            '${zobrazovanyVedouci!.konzument!.nacarkovanychKusu}',
                                            style: const TextStyle(
                                                fontSize: 40,
                                                fontFamily: 'Rye'),
                                          ),
                                          Image.asset(
                                            'assets/nabojnice.png',
                                            width: 60,
                                            height: 60,
                                          ),
                                          Image.asset(
                                            'assets/nabojnice.png',
                                            width: 60,
                                            height: 60,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      context.go(
                                          '/domovska/carkovnikDomovskaKonzument/seznamTransakciKonzumenta');
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                            color: Colors.brown[800]!,
                                            width: 3.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 135, 111, 102)),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/klobouk.png',
                                        width: 70,
                                        height: 70,
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await context.push(
                                        '/domovska/carkovnikDomovskaKonzument/manualniCarkovani',
                                        extra:
                                            AktualniVedouci.vedouci!.konzument);
                                    if (result == true) {
                                      setState(() {
                                        zobrazovanyVedouci =
                                            AktualniVedouci.vedouci;
                                      });
                                    }
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(2.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          border: Border.all(
                                            color: Colors.brown[800]!,
                                            width: 3.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                          color: const Color.fromARGB(
                                              255, 135, 111, 102)),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/pest.png',
                                        width: 65,
                                        height: 65,
                                      ),
                                  )
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            )
                          ],
                        ),
                );
              }
            },
          )),
    );
  }
}
