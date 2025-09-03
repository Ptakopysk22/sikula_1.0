import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sikula/obrazovky/AuthWrapper.dart';
import 'package:sikula/obrazovky/DetailVedouciho.dart';
import 'package:sikula/obrazovky/Domovska.dart';
import 'package:sikula/obrazovky/MasZajem.dart';
import 'package:sikula/obrazovky/OAplikaci.dart';
import 'package:sikula/obrazovky/Prihlasovaci.dart';
import 'package:sikula/obrazovky/SeznamVedoucich.dart';
import 'package:sikula/obrazovky/ZpetnaVazba.dart';
import 'package:sikula/obrazovky/carkovnik/CarkovnikDomovskaHospodar.dart';
import 'package:sikula/obrazovky/carkovnik/CarkovnikDomovskaKonzumnet.dart';
import 'package:sikula/obrazovky/carkovnik/CipoveCarkovani.dart';
import 'package:sikula/obrazovky/carkovnik/DetailKonzumace.dart';
import 'package:sikula/obrazovky/carkovnik/DetailKonzumaceHlavas.dart';
import 'package:sikula/obrazovky/carkovnik/DetailKonzumenta.dart';
import 'package:sikula/obrazovky/carkovnik/DetailKorekce.dart';
import 'package:sikula/obrazovky/carkovnik/DetailObalu.dart';
import 'package:sikula/obrazovky/carkovnik/DetailPolozky.dart';
import 'package:sikula/obrazovky/carkovnik/DetailTransakceKonzumenta.dart';
import 'package:sikula/obrazovky/carkovnik/KonzumaceKonzumenta.dart';
import 'package:sikula/obrazovky/carkovnik/ManualniCarkovani.dart';
import 'package:sikula/obrazovky/carkovnik/NacteniCipuCarkovani.dart';
import 'package:sikula/obrazovky/carkovnik/NastaveniCipu.dart';
import 'package:sikula/obrazovky/carkovnik/NastaveniUctu.dart';
import 'package:sikula/obrazovky/carkovnik/Pokladna.dart';
import 'package:sikula/obrazovky/carkovnik/PokladnaDetail.dart';
import 'package:sikula/obrazovky/carkovnik/PresunMeziUcty.dart';
import 'package:sikula/obrazovky/carkovnik/PridaniKonzumentaNeboZmenaCipu.dart';
import 'package:sikula/obrazovky/carkovnik/PridaniKorekce.dart';
import 'package:sikula/obrazovky/carkovnik/QRplatbaZalohy.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamDobijecu.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamKonzumaci.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamKonzumaciHlavas.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamKonzumentu.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamKorekci.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamObalu.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamPolozek.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamStrelcu.dart';
import 'package:sikula/obrazovky/carkovnik/SeznamTransakciKonzumenta.dart';
import 'package:sikula/obrazovky/carkovnik/Sklipek.dart';
import 'package:sikula/obrazovky/carkovnik/SpravaKreditu.dart';
import 'package:sikula/tridy/BankovniUcet.dart';
import 'package:sikula/tridy/Disciplina.dart';
import 'package:sikula/tridy/Konzumace.dart';
import 'package:sikula/tridy/Konzument.dart';
import 'package:sikula/tridy/Korekce.dart';
import 'package:sikula/tridy/Polozka.dart';
import 'package:sikula/tridy/TransakceKonzumenta.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:sikula/tridy/VratkaObalu.dart';
import 'package:sikula/tridy/Zaloha.dart';
import 'obrazovky/carkovnik/NacteniCipu.dart';
import 'obrazovky/carkovnik/ZalohyKonzumenta.dart';

class WidgetTree {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthWrapper(); // Zabalíme celou aplikaci do AuthWrapperu
        },
        routes: <RouteBase>[
          GoRoute(
            path: 'prihlasovaci',
            builder: (BuildContext context, GoRouterState state) {
              return const Prihlasovaci();
            },
          ),
          GoRoute(
            path: 'domovska',
            builder: (BuildContext context, GoRouterState state) {
              return Domovska();
            },
            routes: <RouteBase>[
              GoRoute(
                path: 'masZajem',
                builder: (BuildContext context, GoRouterState state) {
                  Disciplina disciplina = state.extra as Disciplina;
                  return MasZajem(disciplina: disciplina);
                },
              ),
              GoRoute(
                path: 'zpetnaVazba',
                builder: (BuildContext context, GoRouterState state) {
                  return ZpetnaVazba();
                },
              ),
              GoRoute(
                path: 'oAplikaci',
                builder: (BuildContext context, GoRouterState state) {
                  return const OAplikaci();
                },
              ),
              GoRoute(
                path: 'seznamVedoucich',
                builder: (BuildContext context, GoRouterState state) {
                  return const SeznamVedoucich();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'detailVedouciho',
                    builder: (BuildContext context, GoRouterState state) {
                      Vedouci zobrazovanyVedouci = state.extra as Vedouci;
                      return DetailVedouciho(
                          zobrazovanyVedouci: zobrazovanyVedouci);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'carkovnikDomovskaKonzument',
                builder: (BuildContext context, GoRouterState state) {
                  bool? prichodCipem = state.extra as bool?;
                  return CarkovnikDomovskaKonzument(prichodCipem: prichodCipem);
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'seznamStrelcu',
                    builder: (BuildContext context, GoRouterState state) {
                      return SeznamStrelcu();
                    },
                  ),
                  GoRoute(
                    path: 'seznamDobijecu',
                    builder: (BuildContext context, GoRouterState state) {
                      return SeznamDobijecu();
                    },
                  ),
                  GoRoute(
                    path: 'seznamKonzumaciHlavas',
                    builder: (BuildContext context, GoRouterState state) {
                      return SeznamKonzumaciHlavas();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailKonzumaceHlavas',
                        builder: (BuildContext context, GoRouterState state) {
                          Konzumace zobrazovanaKonzumace =
                              state.extra as Konzumace;
                          return DetailKonzumaceHlavas(
                              zobrazovanaKonzumace: zobrazovanaKonzumace);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'manualniCarkovani',
                    builder: (BuildContext context, GoRouterState state) {
                      Konzument zobrazovanyKonzument = state.extra as Konzument;
                      return ManualniCarkovani(
                          zobrazovanyKonzument: zobrazovanyKonzument);
                    },
                  ),
                  GoRoute(
                    path: 'seznamTransakciKonzumenta',
                    builder: (BuildContext context, GoRouterState state) {
                      return SeznamTransakciKonzumenta();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailTransakceKonzumenta',
                        builder: (BuildContext context, GoRouterState state) {
                          TransakceKonzumenta zobrazovanaTransakceKonzumenta =
                              state.extra as TransakceKonzumenta;
                          return DetailTransakceKonzumenta(
                              zobrazovanaTransakceKonzumenta:
                                  zobrazovanaTransakceKonzumenta);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                      path: 'nacteniCipuCarkovani',
                      builder: (BuildContext context, GoRouterState state) {
                        return const NacteniCipuCarkovani();
                      },
                      routes: <RouteBase>[
                        //dřiv zde čipové čárkování, ale asi může být na stejné urovni
                      ]),
                  GoRoute(
                    path: 'cipoveCarkovani',
                    builder: (BuildContext context, GoRouterState state) {
                      Konzument konzument = state.extra as Konzument;
                      return CipoveCarkovani(konzument: konzument);
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'carkovnikDomovskaHospodar',
                builder: (BuildContext context, GoRouterState state) {
                  return const CarkovnikDomovskaHospodar();
                },
                routes: <RouteBase>[
                  GoRoute(
                    path: 'seznamKonzumentu',
                    builder: (BuildContext context, GoRouterState state) {
                      return const SeznamKonzumentu();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'pridaniKonzumentaNeboZmenaCipu',
                        builder: (BuildContext context, GoRouterState state) {
                          Vedouci zobrazovanyVedouci = state.extra as Vedouci;
                          return PridaniKonzumentaNeboZmenaCipu(
                            vedouci: zobrazovanyVedouci,
                          );
                        },
                        routes: <RouteBase>[
                          GoRoute(
                              path: 'nacteniCipu',
                              builder:
                                  (BuildContext context, GoRouterState state) {
                                Vedouci zobrazovanyVedouci =
                                    state.extra as Vedouci;
                                return NacteniCipu(vedouci: zobrazovanyVedouci);
                              },
                              routes: <RouteBase>[
                                GoRoute(
                                  path: 'nastaveniCipu',
                                  builder: (BuildContext context,
                                      GoRouterState state) {
                                    return const NastaveniCipu();
                                  },
                                ),
                              ]),
                        ],
                      ),
                      GoRoute(
                        path: 'detailKonzumenta',
                        builder: (BuildContext context, GoRouterState state) {
                          Konzument zobrazovanyKonzument =
                              state.extra as Konzument;
                          return DetailKonzumenta(
                              zobrazovanyKonzument: zobrazovanyKonzument);
                        },
                      ),
                      GoRoute(
                        path: 'zalohyKonzumenta',
                        builder: (BuildContext context, GoRouterState state) {
                          Konzument zobrazovanyKonzument =
                              state.extra as Konzument;
                          return ZalohyKonzumenta(
                              zobrazovanyKonzument: zobrazovanyKonzument);
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'spravaKreditu',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              final extra = state.extra;
                              if (extra is Zaloha) {
                                return SpravaKreditu(zobrazovanaZaloha: extra);
                              } else {
                                return const AlertDialog(
                                  title: Text('chyba'),
                                );
                              }
                            },
                            routes: <RouteBase>[
                              GoRoute(
                                path: 'QRplatbaZalohy',
                                builder: (BuildContext context,
                                    GoRouterState state) {
                                  Zaloha zobrazovanaZaloha =
                                      state.extra as Zaloha;
                                  return QRplatbaZalohy(
                                      zobrazovanaZaloha: zobrazovanaZaloha);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'konzumaceKonzumenta',
                        builder: (BuildContext context, GoRouterState state) {
                          Konzument zobrazovanyKonzument =
                              state.extra as Konzument;
                          return KonzumaceKonzumenta(
                              zobrazovanyKonzument: zobrazovanyKonzument);
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'manualniCarkovani',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              Konzument zobrazovanyKonzument =
                                  state.extra as Konzument;
                              return ManualniCarkovani(
                                  zobrazovanyKonzument: zobrazovanyKonzument);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'seznamPolozek',
                    builder: (BuildContext context, GoRouterState state) {
                      return const SeznamPolozek();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailPolozky',
                        builder: (BuildContext context, GoRouterState state) {
                          final extra = state.extra;
                          if (extra is Polozka) {
                            return DetailPolozky(zobrazovanaPolozka: extra);
                          } else {
                            return const AlertDialog(
                              title: Text('chyba'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'seznamKonzumaci',
                    builder: (BuildContext context, GoRouterState state) {
                      return const SeznamKonzumaci();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailKonzumace',
                        builder: (BuildContext context, GoRouterState state) {
                          Konzumace zobrazovanaKonzumace =
                              state.extra as Konzumace;
                          return DetailKonzumace(
                              zobrazovanaKonzumace: zobrazovanaKonzumace);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'pokladna',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Pokladna();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'pokladnaDetail',
                        builder: (BuildContext context, GoRouterState state) {
                          return const PokladnaDetail();
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'nastaveniUctu',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              BankovniUcet bankovniUcet =
                                  state.extra as BankovniUcet;
                              return NastaveniUctu(
                                bankovniUcet: bankovniUcet,
                              );
                            },
                          ),
                          GoRoute(
                            path: 'presunMeziUcty',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              return const PresunMeziUcty();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'sklipek',
                    builder: (BuildContext context, GoRouterState state) {
                      return const Sklipek();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'pridaniKorekce',
                        builder: (BuildContext context, GoRouterState state) {
                          Polozka zobrazovanaPolozka = state.extra as Polozka;
                          return PridaniKorekce(
                              zobrazovanaPolozka: zobrazovanaPolozka);
                        },
                      ),
                      GoRoute(
                        path: 'seznamKorekci',
                        builder: (BuildContext context, GoRouterState state) {
                          return const SeznamKorekci();
                        },
                        routes: <RouteBase>[
                          GoRoute(
                            path: 'detailKorekce',
                            builder:
                                (BuildContext context, GoRouterState state) {
                              Korekce zobrazovanaKorekce =
                                  state.extra as Korekce;
                              return DetailKorekce(
                                  zobrazovanaKorekce: zobrazovanaKorekce);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'seznamObalu',
                    builder: (BuildContext context, GoRouterState state) {
                      return const SeznamObalu();
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'detailObalu',
                        builder: (BuildContext context, GoRouterState state) {
                          final extra = state.extra;
                          if (extra is VratkaObalu) {
                            return DetailObalu(zobrazovanyObal: extra);
                          } else {
                            return const AlertDialog(
                              title: Text('chyba'),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
