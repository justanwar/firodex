import 'package:test/test.dart';
import 'package:web_dex/shared/utils/validators.dart';

void testValidatePassword() {
  test('Get from Coin usd price and return formatted string', () {
    const errorMsg = 'Error';
    expect(validatePassword('passwordwith Space', errorMsg), errorMsg);
    expect(validatePassword('passwordwith Space!', errorMsg), null);
    expect(validatePassword('passwordwith_Space', errorMsg), null);
    expect(validatePassword('passwordwith_Space!', errorMsg), null);
    expect(validatePassword('ABCdec123123!', errorMsg), null);
    expect(validatePassword('123123', errorMsg), errorMsg);
    expect(validatePassword('ABCDEF', errorMsg), errorMsg);
    expect(validatePassword('abcdef', errorMsg), errorMsg);
    expect(validatePassword('!@#%', errorMsg), errorMsg);
    expect(validatePassword('', errorMsg), errorMsg);
  });
}
