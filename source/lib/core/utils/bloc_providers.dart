import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocProviders {
  static get getproviders => [
    // BlocProvider(create: (_) => locator<LoginBloc>()),
  ];

  static void resetAllBlocs(BuildContext context) {
    // context
    //     .read<ActivitySavedContentListBloc>()
    //     .add(const ActivitySavedContentListEvent.reset());
  }
}

Widget getBlocWrapper(Widget child) {
  final providers = BlocProviders.getproviders;

  if (providers.isEmpty) {
    return child;
  } else {
    return MultiBlocProvider(
      providers: providers,
      child: child,
    );
  }
}