import 'package:flutter/material.dart';

/// Holds a nullable global [BuildContext] for code outside the widget tree; prefer passing context explicitly when possible.
class ContextProvider extends ChangeNotifier {
  BuildContext? _context;

  BuildContext? get context => _context;

  void setContext(BuildContext context) {
    _context = context;
    notifyListeners();
  }

  void clearContext() {
    _context = null;
    notifyListeners();
  }
}
