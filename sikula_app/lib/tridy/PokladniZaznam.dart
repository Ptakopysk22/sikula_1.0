class PokladniZaznam {
  final int id; // u zálohy je to id zálohy u nákupu to je id_polozka
  final double? castka;
  final String nadpis;
  final String typTransakce;
  final String ucet;
  final String vyridil;
  final DateTime datumAcas;

  PokladniZaznam(
      {required this.id,
      required this.castka,
      required this.nadpis,
      required this.typTransakce,
      required this.ucet,
      required this.vyridil,
      required this.datumAcas});
}
