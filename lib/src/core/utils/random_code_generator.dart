import 'dart:math';

class RandomCodeGenerator {
  static String generateCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }
}
