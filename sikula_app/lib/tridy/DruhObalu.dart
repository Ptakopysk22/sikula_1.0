enum DruhObalu {
  Lahve,
  Prepravky;

  //zde nepužitelné, enum neumí písmeno ř

  String get nazev {
    switch (this) {
      case DruhObalu.Lahve:
        return 'Lahve';
      case DruhObalu.Prepravky:
        return 'Přepravky';
    }
  }
}

extension DruhObaluExtension on DruhObalu {
  static DruhObalu fromString(String value) {
    return DruhObalu.values
        .firstWhere((e) => e.toString().split('.').last == value);
  }
}

extension DruhObaluExtension2 on DruhObalu {
  static List<String> get names => DruhObalu.values.map((d) => d.name).toList();
}
