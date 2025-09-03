import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sikula/WidgetTree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikula/controllers/VedouciController.dart';
import 'package:sikula/tridy/Vedouci.dart';
import 'package:uni_links/uni_links.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Skrytí spodní lišty
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  StreamSubscription? _sub;
  late GoRouter _router;
  VedouciController vedouciController = VedouciController();

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
    _initDeepLinkListener();
    _handleInitialDeepLink();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  GoRouter _createRouter() {
    return WidgetTree().router;
  }

  void _initDeepLinkListener() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (Object err) {
      print('Error occurred while listening to deep link: $err');
    });
  }

  Future<void> _handleInitialDeepLink() async {
    try {
      final Uri? initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (err) {
      print('Failed to get initial deep link: $err');
    }
  }

  void _handleDeepLink(Uri uri) async {
    print('moje: ${uri.scheme} a ${uri.host}');
    if (uri.scheme == 'sikula' && uri.host == 'open') {
      final User? user = FirebaseAuth.instance.currentUser;
      Vedouci aktualniVedouci = await vedouciController.vratVedouciho(user!);
      if (aktualniVedouci == null) {
           _router.go('/prihlasovaci');
      } else if (aktualniVedouci.konzument == null) {
         _router.go('/domovska/carkovnikDomovskaKonzument');
      } else {
        //final String path = uri.path;
        _router.go('/domovska/carkovnikDomovskaKonzument', extra: true);
      }
    } else {
      print('Unsupported URI scheme or host');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
      theme: ThemeData(
        primaryColor: Colors.grey[500],
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[300],
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor:
              Colors.black.withOpacity(0.2), // Nastavení barvy výběru
          selectionHandleColor: Colors.black,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[700],
          iconTheme: const IconThemeData(
            color: Colors.white,
          ), // Nastavení barvy šipky zpět
          titleTextStyle: const TextStyle(
            letterSpacing: 3,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          bodySmall: TextStyle(
            fontSize: 17,
          ),
          bodyMedium: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          bodyLarge: TextStyle(
            letterSpacing: 3,
            fontSize: 50,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.red,
        ),
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}


