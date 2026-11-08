import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:example/core/developer_tools/api_logs/api_log_model.dart';

void main() {
  test('maskBody masks sensitive keys recursively', () {
    final masked = maskBody({
      'password': 'a',
      'password_confirmation': 'a',
      'otp': '123456',
      'data': [
        {'access_token': 'x', 'name': 'ok'},
      ],
    });
    expect(masked['password'], '****');
    expect(masked['password_confirmation'], '****');
    expect(masked['otp'], '****');
    expect(masked['data'][0]['access_token'], '****');
    expect(masked['data'][0]['name'], 'ok');
  });

  test('JSON bytes body is decoded then masked', () {
    final bytes = utf8.encode(jsonEncode({'token': 'x', 'a': 1}));
    expect(maskBody(bytes), {'token': '****', 'a': 1});
  });

  test('non-JSON bytes body is summarized', () {
    expect(maskBody([0xff, 0xfe, 0x00]), '(binary, 3 bytes)');
  });
}
