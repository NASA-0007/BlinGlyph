import 'glyph_map.dart';
enum Phone {
  unknown(0),
  phone1(1),
  phone2(2),
  phone2a(3);

  final int idx;

  const Phone(this.idx);

  static Phone fromIndex(int index) {
    return Phone.values.firstWhere((e) => e.idx == index, orElse: () => Phone.unknown);
  }

  String get formattedName {
    switch (this) {
      case Phone.phone1:
        return "Phone (1)";
      case Phone.phone2:
        return "Phone (2)";
      case Phone.phone2a:
        return "Phone (2a)";
      default:
        return "Unsupported";
    }
  }

  int get calculateTotalZones {
    switch (this) {
      case Phone.phone1:
        return Phone1GlyphMap.values.length;

      case Phone.phone2:
        return Phone2GlyphMap.values.length;

      case Phone.phone2a:
        return Phone2aGlyphMap.values.length;
      default:
        throw UnimplementedError();
    }
  }

  static Future<Phone> guessCurrentPhone(GlyphInterface glyphInterface) async {
    var isPhone1 = await glyphInterface.isPhone1();
    var isPhone2 = await glyphInterface.isPhone2();
    var isPhone2a = await glyphInterface.isPhone2a();

    if (isPhone1) {
      return Phone.phone1;
    }
    if (isPhone2) {
      return Phone.phone2;
    }
    if (isPhone2a) {
      return Phone.phone2a;
    }
    return Phone.unknown;
  }
}

// Define your glyph interface
abstract class GlyphInterface {
  Future<bool> isPhone1();
  Future<bool> isPhone2();
  Future<bool> isPhone2a();
}

class Phoneis extends GlyphInterface {
  @override
  Future<bool> isPhone1()
  {
    return Future.value(false);
  }
  Future<bool> isPhone2()
  {
    return Future.value(true);
  }
  Future<bool> isPhone2a()
  {
    return Future.value(true);
  }
}