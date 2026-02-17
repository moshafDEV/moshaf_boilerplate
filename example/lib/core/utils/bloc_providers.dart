import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviders {
  static get getproviders => [
    // Add your BlocProviders here for Global access, for example:
    // BlocProvider(create: (_) => locator<LoginBloc>()),
  ];
}

Widget getBlocWrapper(Widget child) {
  final providers = BlocProviders.getproviders;

  if (providers.isEmpty) {
    return child;
  } else {
    return MultiBlocProvider(providers: providers, child: child);
  }
}
