import 'package:flutter_test/flutter_test.dart';
import 'package:example/core/routes/app_path.dart';
import 'package:example/core/routes/app_router.dart';

void main() {
  group('redirectDecision', () {
    test('splash is always let through, authed or not', () {
      expect(
        redirectDecision(isAuthed: false, location: Paths.splash),
        isNull,
      );
      expect(
        redirectDecision(isAuthed: true, location: Paths.splash),
        isNull,
      );
    });

    test('about is always let through, authed or not', () {
      expect(
        redirectDecision(isAuthed: false, location: Paths.about),
        isNull,
      );
      expect(
        redirectDecision(isAuthed: true, location: Paths.about),
        isNull,
      );
    });

    test('unauthed + public route is allowed', () {
      expect(
        redirectDecision(isAuthed: false, location: Paths.welcome),
        isNull,
      );
      expect(
        redirectDecision(isAuthed: false, location: Paths.login),
        isNull,
      );
    });

    test('unauthed + private route redirects to welcome', () {
      expect(
        redirectDecision(isAuthed: false, location: Paths.home),
        Paths.welcome,
      );
    });

    test('authed + public route redirects to home', () {
      expect(
        redirectDecision(isAuthed: true, location: Paths.welcome),
        Paths.home,
      );
      expect(
        redirectDecision(isAuthed: true, location: Paths.login),
        Paths.home,
      );
    });

    test('authed + private route is allowed', () {
      expect(
        redirectDecision(isAuthed: true, location: Paths.home),
        isNull,
      );
    });
  });
}
