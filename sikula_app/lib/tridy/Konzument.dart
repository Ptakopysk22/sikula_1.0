class Konzument {
  final int? id;
  final String prezdivka;
  late String? cip;
  late double? kredit;
  late int? zkonzumovanychKusu;
  late int? nacarkovanychKusu;
  late int? poradi;

  Konzument({required this.id, required this.prezdivka, this.cip, this.kredit, this.zkonzumovanychKusu, this.nacarkovanychKusu, this.poradi});

  vratPrezdivku() {
    return prezdivka;
  }
}
