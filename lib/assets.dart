import 'package:flutter/material.dart';

class $AssetsImagesGlyphsGen {
  const $AssetsImagesGlyphsGen();

  /// File path: assets/images/glyphs/Phone-1-glyphs.gif
  String get phone1Glyphs => 'asset/images/glyphs/Phone-1-glyphs.gif';

  /// File path: assets/images/glyphs/Phone-2-glyphs.gif
  String get phone2Glyphs => 'asset/images/glyphs/Phone-2-glyphs.gif';

  /// File path: assets/images/glyphs/Phone-2a-glyphs.gif
  String get phone2aGlyphs => 'asset/images/glyphs/Phone-2a-glyphs.gif';

  /// File path: assets/images/glyphs/unknown.gif
  String get Unknown => 'asset/images/glyphs/Unknown.gif';
  /// Method to get a widget for displaying the GIF based on phone type
  Widget getGifDisplay(String phoneType) {
    String gifPath;

    switch (phoneType) {
      case 'Phone (1)':
        gifPath = phone1Glyphs;
        break;
      case 'Phone (2)':
        gifPath = phone2Glyphs;
        break;
      case 'Phone (2a)':
        gifPath = phone2aGlyphs;
        break;
      default:
        gifPath = Unknown; // default case
    }

    return Image.asset(gifPath);
  }
}
