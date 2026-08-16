import 'package:flutter/widgets.dart';

/// Pops [context]'s own route only if it's still mounted and current — guards against a racing second pop tearing down the page underneath (e.g. from a timer or async callback).
void safePop<T extends Object?>(BuildContext context, [T? result]) {
  if (!context.mounted) return;
  final route = ModalRoute.of(context);
  if (route == null || !route.isCurrent) return;
  Navigator.of(context).pop(result);
}
