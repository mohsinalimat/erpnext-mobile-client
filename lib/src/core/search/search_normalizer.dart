String normalizeForSearch(String input) {
  if (input.trim().isEmpty) {
    return '';
  }

  final buffer = StringBuffer();
  final lower = input.toLowerCase();
  for (final rune in lower.runes) {
    buffer.write(_mapRune(String.fromCharCode(rune)));
  }

  return buffer
      .toString()
      .replaceAll(RegExp(r"['`ʻʼ’]"), '')
      .replaceAll('ғ', 'g')
      .replaceAll('қ', 'q')
      .replaceAll('ҳ', 'h')
      .replaceAll('ў', 'o')
      .replaceAll('ё', 'yo')
      .replaceAll('ю', 'yu')
      .replaceAll('я', 'ya')
      .replaceAll('ъ', '')
      .replaceAll('ь', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool searchMatches(String query, Iterable<String> values) {
  final needle = normalizeForSearch(query);
  if (needle.isEmpty) {
    return true;
  }

  for (final value in values) {
    if (normalizeForSearch(value).contains(needle)) {
      return true;
    }
  }
  return false;
}

String _mapRune(String char) {
  switch (char) {
    case 'а':
      return 'a';
    case 'б':
      return 'b';
    case 'в':
      return 'v';
    case 'г':
      return 'g';
    case 'д':
      return 'd';
    case 'е':
      return 'e';
    case 'ё':
      return 'yo';
    case 'ж':
      return 'j';
    case 'з':
      return 'z';
    case 'и':
      return 'i';
    case 'й':
      return 'y';
    case 'к':
      return 'k';
    case 'л':
      return 'l';
    case 'м':
      return 'm';
    case 'н':
      return 'n';
    case 'о':
      return 'o';
    case 'п':
      return 'p';
    case 'р':
      return 'r';
    case 'с':
      return 's';
    case 'т':
      return 't';
    case 'у':
      return 'u';
    case 'ф':
      return 'f';
    case 'х':
      return 'x';
    case 'ц':
      return 'ts';
    case 'ч':
      return 'ch';
    case 'ш':
      return 'sh';
    case 'щ':
      return 'sh';
    case 'ъ':
      return '';
    case 'ы':
      return 'i';
    case 'ь':
      return '';
    case 'э':
      return 'e';
    case 'ю':
      return 'yu';
    case 'я':
      return 'ya';
    case 'қ':
      return 'q';
    case 'ғ':
      return 'g';
    case 'ҳ':
      return 'h';
    case 'ў':
      return 'o';
    default:
      return char;
  }
}
