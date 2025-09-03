class BankovniUcet {
  final String zakladniCast;
  final String kodBanky;

  BankovniUcet({required this.zakladniCast, required this.kodBanky});

  @override
  String toString() {
    return '$zakladniCast/$kodBanky';
  }
}
