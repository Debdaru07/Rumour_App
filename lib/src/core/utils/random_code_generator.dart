import 'dart:math';

class RandomCodeGenerator {
  static String generate() {
    final r = Random();
    return (1000 + r.nextInt(9000)).toString();
  }
}
