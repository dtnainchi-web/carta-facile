import 'package:flutter_test/flutter_test.dart';

import 'package:carta_facile/core/strings.dart';

void main() {
  test('all four languages are supported', () {
    expect(supportedLanguages, ['ar', 'fr', 'it', 'en']);
  });
}
