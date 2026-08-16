import 'package:injectable/injectable.dart';
import 'package:ProjectName/core/routes/app_router.dart';

/// Thin go_router wrapper — lets code without a BuildContext (blocs,
/// usecases) still trigger navigation, via DI instead of reaching for
/// `context.go`/`context.push` directly.
@lazySingleton
class NavigationService {
  void goTo(String location) => appRouter.go(location);

  Future<T?> push<T extends Object?>(String location) =>
      appRouter.push<T>(location);

  void replace(String location) => appRouter.replace(location);

  void pop<T extends Object?>([T? result]) => appRouter.pop(result);

  bool canPop() => appRouter.canPop();
}
