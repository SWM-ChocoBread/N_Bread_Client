import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/wiredash.dart';
import 'WiredashLocalizationsKorean.dart';

class CustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const CustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    /// You have to define all languages you want your delegate to support
    /// Klingon == tlh
    return ['ko'].contains(locale.languageCode);
  }

  @override
  Future<WiredashLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'ko':
        // Replace some text to better address your users
        return SynchronousFuture(WiredashLocalizationsKorean());
      default:
        throw "Unsupported locale $locale";
    }
  }

  @override
  bool shouldReload(CustomWiredashTranslationsDelegate old) => false;
}
