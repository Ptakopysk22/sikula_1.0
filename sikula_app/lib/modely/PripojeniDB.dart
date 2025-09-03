import 'package:postgres/postgres.dart';

Connection? pripojeni;

  // vytvoření připojení, pokud existuje použít stávající - ochrana proti opakovanému připojení
Future vytvorSpojeni() async {
  if (pripojeni == null || !pripojeni!.isOpen) {
    try {
      pripojeni = await Connection.open(
        Endpoint(
            // for external device like mobile phone use domain.com or your computer machine IP address (i.e,192.168.0.1,etc)
            host: '192.168.0.???',
            database: 'sikula24',
            username: 'postgres',
            password: 'secret'
           ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      return pripojeni;
    } catch (e) {
      print('Chyba při otevírání spojení: $e');
    }
  }
  return pripojeni;
}
