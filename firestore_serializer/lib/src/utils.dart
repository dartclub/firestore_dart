import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

const _escapeMap = {
  '\b': r'\b', // 08 - backspace
  '\t': r'\t', // 09 - tab
  '\n': r'\n', // 0A - new line
  '\v': r'\v', // 0B - vertical tab
  '\f': r'\f', // 0C - form feed
  '\r': r'\r', // 0D - carriage return
  '\x7F': r'\x7F', // delete
  r'\': r'\\' // backslash
};

final _escapeMapRegexp = _escapeMap.keys.map(_getHexLiteral).join();

final _escapeRegExp = RegExp('[\$\'"\\x00-\\x07\\x0E-\\x1F$_escapeMapRegexp]');

String _getHexLiteral(String input) {
  final rune = input.runes.single;
  final value = rune.toRadixString(16).toUpperCase().padLeft(2, '0');
  return '\\x$value';
}

final _dollarQuoteRegexp = RegExp(r"""(?=[$'"])""");

String _escapeDartString(String value) {
  var hasSingleQuote = false;
  var hasDoubleQuote = false;
  var hasDollar = false;
  var canBeRaw = true;

  value = value.replaceAllMapped(_escapeRegExp, (match) {
    final value = match[0];
    if (value == "'") {
      hasSingleQuote = true;
      return value;
    } else if (value == '"') {
      hasDoubleQuote = true;
      return value;
    } else if (value == r'$') {
      hasDollar = true;
      return value;
    }

    canBeRaw = false;
    return _escapeMap[value] ?? _getHexLiteral(value);
  });

  if (!hasDollar) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        return '"$value"';
      }
    } else {
      return "'$value'";
    }
  }

  if (hasDollar && canBeRaw) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        return 'r"$value"';
      }
    } else {
      return "r'$value'";
    }
  }

  final string = value.replaceAll(_dollarQuoteRegexp, r'\');
  return "'$string'";
}

Object getLiteral(
  DartObject dartObject,
  Iterable<String> typeInformation,
) {
  if (dartObject.isNull) {
    return null;
  }

  final reader = ConstantReader(dartObject);

  String badType;
  if (reader.isSymbol) {
    badType = 'Symbol';
  } else if (reader.isType) {
    badType = 'Type';
  } else if (dartObject.type is FunctionType) {
    badType = 'Function';
  } else if (!reader.isLiteral) {
    badType = dartObject.type.name;
  }

  if (badType != null) {
    badType = typeInformation.followedBy([badType]).join(' > ');
    throw ('`defaultValue` is `$badType`, it must be a literal.'); // TODO throw
  }

  final literal = reader.literalValue;

  if (literal is num || literal is bool) {
    return literal;
  } else if (literal is String) {
    return _escapeDartString(literal);
  } else if (literal is List<DartObject>) {
    return [
      for (var e in literal)
        getLiteral(e, [
          ...typeInformation,
          'List',
        ])
    ];
  } else if (literal is Map<DartObject, DartObject>) {
    final mapTypeInformation = [
      ...typeInformation,
      'Map',
    ];
    return literal.map(
      (k, v) => MapEntry(
        getLiteral(k, mapTypeInformation),
        getLiteral(v, mapTypeInformation),
      ),
    );
  }

  badType = typeInformation.followedBy(['$dartObject']).join(' > ');
  return null;
}
