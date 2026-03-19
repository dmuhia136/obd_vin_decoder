import 'dart:math';
import 'manufacturers.dart';

const _vinChars = "ABCDEFGHJKLMNPRSTUVWXYZ0123456789";
const _letters = "ABCDEFGHJKLMNPRSTUVWXYZ";
const _numbers = "0123456789";
const _yearSequence = "ABCDEFGHJKLMNPRSTVWXY123456789"; // ADDED THIS

class VINGenerator {
  static final _random = Random();

  static String generateWmi() {
    final wmiList = manufacturers.keys.toList();
    String wmi = wmiList[_random.nextInt(wmiList.length)];
    if (wmi.length == 2) wmi += '9';
    return wmi;
  }

  static String generate() {
    final wmi = generateWmi();
    final isPre2010 = _random.nextBool();

    // 1. Pick a random year character from your new sequence
    final yearChar = _yearSequence[_random.nextInt(_yearSequence.length)];

    // 2. Generate VIS
    String serial = '';
    for (int i = 0; i < 6; i++) {
      serial += _numbers[_random.nextInt(_numbers.length)];
    }
    final vis = '${yearChar}A$serial';

    // 3. Generate VDS
    String vdsPrefix = '';
    for (int i = 0; i < 3; i++) {
      vdsPrefix += _vinChars[_random.nextInt(_vinChars.length)];
    }

    // 4. ISO Era Rule (Position 7)
    String pos7 = isPre2010
        ? _numbers[_random.nextInt(_numbers.length)]
        : _letters[_random.nextInt(_letters.length)];

    String pos8 = _vinChars[_random.nextInt(_vinChars.length)];
    String checkDigit = _numbers[_random.nextInt(_numbers.length)];

    final vds = '$vdsPrefix$pos7$pos8$checkDigit';

    return '$wmi$vds$vis';
  }
}