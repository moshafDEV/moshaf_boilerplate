# PROJECT BLUEPRINT — example

> This document describes the architecture, conventions, and code patterns used in this project.
> Use it as a reference when adding a new feature, during PR review (manual or automated), or when onboarding a new developer.
> Every claim here was checked directly against the code — including the "Known Inconsistencies" section, which is documented honestly rather than hidden.

---

## 1. ARCHITECTURE & MAIN PATTERNS

| | |
|---|---|
| **Architecture** | Clean Architecture, **layer-first** (not feature-first) |
| **State management** | `flutter_bloc` — BLoC pattern with `freezed` unions for Event/State |
| **DI** | `get_it` + `injectable` + code generation (`build_runner`) |
| **Router** | [`go_router`](https://pub.dev/packages/go_router) — declarative, a single `redirect` gates auth |
| **HTTP** | `dio` (IO-only — no separate web client variant) |
| **FP / Either** | `dartz` |
| **Code gen** | `freezed`, `json_serializable`, `injectable_generator`, `envied_generator` |
| **Asset codegen** | Its own CLI (`moshaf_boilerplate assets`) — not `flutter_gen`, see §9 |
| **CI/CD** | Jenkins (`Jenkinsfile` + `ci/`), optional — see `ci/docs/` |

---

## 2. FOLDER STRUCTURE

```
lib/
├── app.dart               ← MaterialApp.router, wiring only, no business logic
├── main.dart
├── main_dev.dart          ← dev flavor entry point
├── main_prod.dart         ← prod flavor entry point
│
├── core/
│   ├── analytics/         ← analytics abstraction (Analytic interface + Firebase/NoOp impl)
│   │   └── screen_analytics/
│   ├── config/
│   │   ├── di_module/     ← app_module.dart, init_config.dart, init_config.config.dart (generated)
│   │   └── loggers/       ← crashlytic_logger.dart
│   ├── constants/         ← api_path_constant.dart, colors.dart, textstyle.dart,
│   │                        assets.gen.dart (generated, see §9), assets_gen/ (per-folder generated files)
│   ├── env/               ← env.dart (envied), secure_storage_key.dart
│   ├── error/              ← failure.dart, exception.dart
│   ├── http_client/        ← dio_config.dart, main_client.dart, interceptors/
│   ├── routes/             ← app_path.dart, app_routes.dart, app_router.dart (GoRouter), route_error_page.dart
│   ├── services/           ← navigation_service.dart
│   └── utils/              ← storage_data, validators, safe_pop, navigator_stack_guard, bloc_providers, etc.
│
├── data/
│   ├── datasources/
│   │   └── remote/         ← abstract + impl in one file; @LazySingleton
│   ├── models/
│   │   └── [feature]/
│   │       ├── request/    ← *_req_model.dart
│   │       └── response/   ← *_model.dart / *_response_model.dart
│   └── repository_impls/   ← *_repo_impl.dart; @Injectable(as: Repository)
│
├── domain/
│   ├── entities/
│   │   └── [feature]/      ← *_entity.dart (@freezed, MUST have an .initial() factory)
│   ├── repositories/       ← *_repository.dart (abstract)
│   └── usecase/
│       └── [feature]/      ← 1 file = 1 class = 1 `execute()` method (see §3 — different from "one usecase, many methods")
│
└── presentation/
    ├── bloc/
    │   └── [feature]/      ← *_bloc.dart (+ part *_event.dart, *_state.dart, *.freezed.dart)
    ├── components/         ← shared widgets across pages (chip, dialog_popup, avatar_profile, etc.)
    └── pages/
        └── [feature]/
            ├── [feature]_page.dart
            └── components/     ← widgets local to this page
```

**Project root** (outside `lib/`): `assets/`, `flavorizr.yaml`, `flutter_launcher_icons.yaml`, `flutter_native_splash.yaml`, `Jenkinsfile` + `ci/` (optional, safe to delete if you don't use Jenkins), `test/`.

---

## 3. NAMING CONVENTIONS

### Files & Classes

| Kind | File name pattern | Class name pattern | Real example in this project |
|---|---|---|---|
| Page | `[feature]_page.dart` | `[Feature]Page` | `login_page.dart` → `LoginPage` |
| Shared widget | `[name].dart` | free-form | `chip.dart`, `dialog_popup.dart` |
| Bloc | `[feature]_bloc.dart` | `[Feature]Bloc` | `login_bloc.dart` → `LoginBloc` |
| Event / State | `part of` the same bloc file, not a standalone import | `[Feature]Event` / `[Feature]State` | `login_event.dart`/`login_state.dart`, both `part of 'login_bloc.dart'` |
| Entity | `[name]_entity.dart` | `[Name]Entity`, must have `.initial()` | `login_param_entity.dart` → `LoginParamEntity` |
| UseCase | `[name].dart` | `[Name]Usecase`, single `execute()` method | `login.dart` → `LoginUsecase.execute()` |
| Repository (abstract) | `[feature]_repository.dart` | `[Feature]Repository` | `auth_repository.dart` → `AuthRepository` |
| Repository (impl) | `[feature]_repo_impl.dart` | **should be** `[Feature]RepoImpl` — see §11, in practice it's still `[Feature]RemoteDatasourceImpl` | — |
| Datasource | `[feature]_remote_datasource.dart` | `[Feature]RemoteDatasource` + `[Feature]RemoteDatasourceImpl` in one file | `auth_remote_datasource.dart` |
| Response model | `[name]_model.dart` | `[Name]Model` (or `[Name]ResponseModel` for a wrapper) — **keep it consistent**, see §11 | — |
| Request model | `[name]_req_model.dart` | `[Name]ReqParamModel`, uses `@JsonSerializable` + `.fromDomain()` | `login_req_param_model.dart` → `LoginReqParamModel` |

### Variables & Functions

| Kind | Convention | Example |
|---|---|---|
| Private field | `_camelCase` | `_repository`, `_client` |
| Boolean state | `isLoading`, `success[Feature]` | `isLoading`, `successLogin` |
| Error state field | `errorResponseMessage` (type `String`, not `Failure?`) | see §8 — different from the "flash & reset" pattern |
| API path constant | `U` prefix + PascalCase, in class `ApiPath` | `ULogin`, `UUserProfile` |
| Route constant | `camelCase` in class `Paths` | `Paths.forgotPassword`, `Paths.home` |
| Async fetch in usecase | `execute()` — not a feature-named `get*`/`submit*` | `loginUsecase.execute(params)` |
| Freezed union event case | `on` prefix + PascalCase action | `LoginEvent.onEmailChanged`, `.onSubmit()` |

### Import Order

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// other third-party packages
import 'package:example/core/...';
import 'package:example/domain/...';
import 'package:example/data/...';
import 'package:example/presentation/...';
```

---

## 4. CODE PATTERNS PER LAYER

### Domain — Entity

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'xxx_entity.freezed.dart';

@freezed
abstract class XxxEntity with _$XxxEntity {
  const factory XxxEntity({
    required String id,
    required String name,
  }) = _XxxEntity;

  // REQUIRED — every entity in this project has this, no exceptions (5/5 currently)
  factory XxxEntity.initial() => const XxxEntity(id: '', name: '');
}
```

### Domain — Repository (abstract)

```dart
import 'package:dartz/dartz.dart';
import 'package:example/core/error/failure.dart';

abstract class XxxRepository {
  Future<Either<Failure, XxxEntity>> getXxx();
}
```

### Domain — UseCase

One class = one `execute()` method. **Not** one class bundling many domain methods per feature.

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/error/failure.dart';

@injectable
class XxxUsecase {
  final XxxRepository _repository;

  XxxUsecase(this._repository);

  Future<Either<Failure, XxxEntity>> execute(XxxParamEntity params) async {
    return await _repository.getXxx(params);
  }
}
```

### Data — Response Model

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:example/domain/entities/xxx/xxx_entity.dart';
part 'xxx_model.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class XxxModel {
  final String? id;
  final String? name;

  XxxModel({this.id, this.name});

  factory XxxModel.fromJson(Map<String, dynamic> json) => _$XxxModelFromJson(json);
  Map<String, dynamic> toJson() => _$XxxModelToJson(this);

  // Model → entity conversion lives on the model (data layer), not in the repo impl
  XxxEntity toDomain() => XxxEntity(id: id ?? '', name: name ?? '');

  // For the reverse direction (e.g. local cache or mocks), if needed
  factory XxxModel.fromDomain(XxxEntity domain) =>
      XxxModel(id: domain.id, name: domain.name);
}
```

### Data — Request Model

```dart
@JsonSerializable(includeIfNull: false, explicitToJson: true)
class XxxReqParamModel {
  final String id;

  XxxReqParamModel({required this.id});

  Map<String, dynamic> toJson() => _$XxxReqParamModelToJson(this);

  factory XxxReqParamModel.fromDomain(XxxParamEntity entity) =>
      XxxReqParamModel(id: entity.id);
}
```

### Data — Datasource (abstract + impl in one file)

Error mapping happens **here**, per method, directly in `catch (DioException e)` — not through a centralized helper (see §8 on `ErrorHandling.handleException`, which exists but isn't used).

```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:example/core/constants/api_path_constant.dart';
import 'package:example/core/error/exception.dart';
import 'package:example/core/error/failure.dart';
import 'package:example/core/http_client/main_client.dart';

abstract class XxxRemoteDatasource {
  Future<Either<Failure, XxxModel>> getXxx();
}

@LazySingleton(as: XxxRemoteDatasource)
class XxxRemoteDatasourceImpl implements XxxRemoteDatasource {
  final MainClient _client;
  XxxRemoteDatasourceImpl(this._client);

  @override
  Future<Either<Failure, XxxModel>> getXxx() async {
    try {
      final response = await _client.get(ApiPath.UXxx);
      return right(XxxModel.fromJson(response.data));
    } on DioException catch (e) {
      return left(ServerFailure(
        extractErrorMessage(e.response?.data,
            fallback: e.response?.statusMessage ?? 'Something went wrong'),
        e.response?.statusCode,
      ));
    } catch (e) {
      return left(ServerFailure('Unexpected error', e.toString()));
    }
  }
}
```

### Data — Repository Impl

**The correct class name** is `XxxRepoImpl` (matching the file name) — see §11: in the code that exists today (`auth_repo_impl.dart`/`profile_repo_impl.dart`) the class got copy-pasted as `XxxRemoteDatasourceImpl` instead. Follow the pattern BELOW for new code — don't copy the old one.

```dart
import 'package:injectable/injectable.dart';

@Injectable(as: XxxRepository)
class XxxRepoImpl implements XxxRepository {
  final XxxRemoteDatasource remoteDataSource;

  XxxRepoImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, XxxEntity>> getXxx() async {
    final apiResult = await remoteDataSource.getXxx();
    if (apiResult.isLeft()) {
      return left((apiResult as Left).value);
    }
    final response = (apiResult as Right).value;
    return right(response.toDomain());
  }
}
```

### Presentation — Bloc + Event + State (1 group, 3 files via `part`)

```dart
// xxx_bloc.dart
import 'package:injectable/injectable.dart';
part 'xxx_bloc.freezed.dart';
part 'xxx_event.dart';
part 'xxx_state.dart';

@injectable
class XxxBloc extends Bloc<XxxEvent, XxxState> {
  final XxxUsecase _xxxUsecase;

  XxxBloc(this._xxxUsecase) : super(XxxState.initial()) {
    on<XxxEvent>(_onXxxEvent);
  }

  Future<void> _onXxxEvent(XxxEvent event, Emitter<XxxState> emit) async {
    switch (event) {
      case _OnFetchXxx():
        emit(state.copyWith(isLoading: true));
        final result = await _xxxUsecase.execute();
        result.fold(
          (failure) => emit(state.copyWith(isLoading: false, errorResponseMessage: failure.message)),
          (response) => emit(state.copyWith(isLoading: false, xxx: response)),
        );
    }
  }
}
```

```dart
// xxx_event.dart
part of 'xxx_bloc.dart';

@freezed
abstract class XxxEvent with _$XxxEvent {
  const factory XxxEvent.onFetchXxx() = _OnFetchXxx;
}
```

```dart
// xxx_state.dart
part of 'xxx_bloc.dart';

@freezed
abstract class XxxState with _$XxxState {
  factory XxxState({
    @Default(false) bool isLoading,
    required XxxEntity xxx,
    @Default('') String errorResponseMessage,
  }) = _XxxState;

  factory XxxState.initial() => XxxState(isLoading: false, xxx: XxxEntity.initial());
}
```

---

## 5. DI — REGISTRATION

### `app_module.dart` (things that need factory logic, not a plain constructor)

```dart
@module
abstract class AppModule {
  @lazySingleton
  MainClient get userClient => MainClient();

  // A factory getter (not @LazySingleton directly on the Analytic class) so
  // the implementation choice is made at runtime from Env.enableFirebase +
  // platform support, instead of always constructing FirebaseAnalytic —
  // which would touch FirebaseAnalytics.instance even where Firebase was
  // never initialized (Windows/Linux).
  @lazySingleton
  Analytic get analytic => (Env.enableFirebase && isFirebaseSupported)
      ? FirebaseAnalytic()
      : NoOpAnalytic();
}
```

### Classes that just need `@injectable`/`@lazySingleton` directly (no `app_module.dart` needed)

Usecases, Blocs, Datasources, Repository impls, and `NavigationService` — all annotated directly on the class itself (`@injectable`, `@LazySingleton(as: ...)`, `@Injectable(as: ...)`). `app_module.dart` is only for things that need factory logic like the example above.

### `init_config.dart`

```dart
final getIt = GetIt.instance;

@InjectableInit(initializerName: r'$initGetIt', preferRelativeImports: true, asExtension: false)
Future<void> initConfig() async {
  await configureDependencies();
  await initSecureStorage();
  await SecureStorageUtils.setStorage(localeLangId, 'id');
}

Future<void> configureDependencies() async => await $initGetIt(getIt);
```

---

## 6. ROUTING (go_router)

### `app_path.dart` — path constants

```dart
abstract class Paths {
  Paths._();
  static const home = '/home';
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
}
```

### `app_routes.dart` — the `GoRoute` list

```dart
final List<RouteBase> appRoutes = [
  GoRoute(path: Paths.home, builder: (context, state) => const HomePage()),
  GoRoute(path: Paths.login, builder: (context, state) => LoginPage()),
  // etc — no `arguments:` like the old Navigator API; if you need to pass
  // data between pages, use go_router's own `extra:` or a path parameter
  // (`:id`), NOT ModalRoute.of(context)!.settings.arguments.
];
```

### `app_router.dart` — singleton `GoRouter`, one `redirect` for the auth gate

The auth gate (splash/welcome/login/home) is centralized into ONE `redirect` function, instead of being checked manually on every page:

```dart
FutureOr<String?> _redirect(BuildContext context, GoRouterState state) async {
  final accessToken = await SecureStorageUtils.getStorage(bearerToken);
  return redirectDecision(isAuthed: accessToken.isNotEmpty, location: state.matchedLocation);
}

final GoRouter appRouter = GoRouter(
  initialLocation: Paths.splash,
  routes: appRoutes,
  redirect: _redirect,
  observers: [ChuckerFlutter.navigatorObserver, navigatorStackGuard],
  errorBuilder: (context, state) { /* -> RouteErrorPage, reports to ErrorReporter */ },
);
```

**The `redirect` decision logic is extracted into a pure function `redirectDecision({required bool isAuthed, required String location})`**, marked `@visibleForTesting`, so it's testable without mocking `flutter_secure_storage`'s platform channel. See `test/core/routes/app_router_test.dart` for the decision-matrix test (4 auth×public-route scenarios). **If you add a new route that needs the auth gate, don't put auth logic on the page — update `_publicRoutes`/`redirectDecision` in `app_router.dart`.**

### Navigation

```dart
context.go(Paths.home);       // replace the stack (used for auth-gated transitions)
context.push(Paths.register); // push on top of the stack (used for "optional" pages with a back button)
context.pop();                // replaces Navigator.of(context).pop()
```

### `NavigationService` — a thin wrapper, not the old imperative API

```dart
@lazySingleton
class NavigationService {
  void goTo(String location) => appRouter.go(location);
  Future<T?> push<T>(String location) => appRouter.push<T>(location);
  void pop<T>([T? result]) => appRouter.pop(result);
}
```
Use this when you need to navigate from somewhere without a `BuildContext` (a bloc, a usecase). If you already have a `BuildContext`, `context.go`/`context.push` is simpler.

---

## 7. GLOBAL vs LOCAL BLOC

**Right now this project only uses local/route-scoped blocs.** `core/utils/bloc_providers.dart` EXISTS as a scaffold (`BlocProviders.getproviders` + `getBlocWrapper()`) but is **empty and never called** from `app.dart` — if you need a global bloc (state that must survive across pages, e.g. profile/theme), fill in that list and call `getBlocWrapper(child)` in `app.dart` before wrapping `MaterialApp.router`.

The local-bloc pattern currently used — constructed directly on the page, NOT resolved via `getIt<XxxBloc>()`:

```dart
class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(getIt<LoginUsecase>(), getIt<ProfileUsecase>()),
      child: const LoginPageContent(),
    );
  }
}
```
Since `LoginBloc` is already `@injectable`, this could just as well be `create: (context) => getIt<LoginBloc>()` — the two aren't unified yet, and both work technically.

---

## 8. ERROR HANDLING PATTERN

### `Failure` hierarchy

```dart
abstract class Failure extends Equatable {
  final String message;
  final dynamic code;
  const Failure(this.message, this.code);
}

class ServerFailure extends Failure { ... }
class ConnectionFailure extends Failure { ... }
class DatabaseFailure extends Failure { ... }
```

⚠️ There's also `NotFoundException` and `FormatException` as `Failure` subclasses (not `Exception`) — misleading names, and `FormatException` shadows `dart:core`'s own `FormatException` by name. Don't add new `Failure` subclasses with an `...Exception` naming pattern — use `...Failure`.

### Mapping DioException → Failure

Done **per method in the datasource**, not through a centralized helper:

```dart
} on DioException catch (e) {
  return left(ServerFailure(
    extractErrorMessage(e.response?.data, fallback: e.response?.statusMessage ?? 'Something went wrong'),
    e.response?.statusCode,
  ));
}
```

`ErrorHandling.handleException` (in `core/error/exception.dart`) EXISTS but **isn't called anywhere** — don't treat it as the reference; follow the inline pattern above for new datasources.

### Consuming errors in the Bloc

State in this project uses a `String errorResponseMessage` field (not a `Failure?` auto-reset via a "flash & reset" pattern like some sibling projects) — reset manually at the start of the next event handler (`emit(state.copyWith(errorResponseMessage: ''))`), not an automatic double-emit.

---

## 9. ASSETS & STYLING

### Colors & text — `core/constants/colors.dart` / `textstyle.dart`

Flat `const`/`final`, not via `ColorScheme`/`ThemeData.textTheme`:
```dart
Text('Hello', style: genStyle14Bold.copyWith(color: kMainPrimary));
```
`genStyle(size, weight, {color})` is a factory — if you need a size that doesn't have a const yet, call it directly instead of adding a new const.

### Assets — `moshaf_boilerplate assets`

`lib/core/constants/assets.gen.dart` (barrel) + `lib/core/constants/assets_gen/*.gen.dart` (one file per top-level folder under `assets/`) are auto-generated — **DO NOT edit by hand**. Regenerate whenever you add or remove a file under `assets/`:
```bash
moshaf_boilerplate assets
```
Use: `Assets.images.imgLanding`, `Assets.svg.iconSearch`, etc. — not a raw string path.

### App icon & splash screen

`flutter_launcher_icons.yaml`/`flutter_native_splash.yaml` at the project root — fill in your own image paths (still placeholders by default), then run manually:
```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## 10. FLAVOR / ENVIRONMENT

Three entry points: `main.dart` (default), `main_dev.dart`, `main_prod.dart`. Native flavor config (application id, bundle id, icon, launch screen) is managed by `flutter_flavorizr` via `flavorizr.yaml` — run `dart run flutter_flavorizr -f` after any flavor config change. Env vars via `envied` (`core/env/env.dart`); tokens/session via `flutter_secure_storage` (`core/utils/storage_data.dart`).

---

## 11. KNOWN INCONSISTENCIES (do not copy, documented as-is)

This section is documented honestly because this project is still an early-stage boilerplate — the following exist in the code today but deviate from the patterns described above. When building a new feature, follow the patterns in §3-9, NOT these examples:

| Location | Issue |
|---|---|
| `data/repository_impls/auth_repo_impl.dart`, `profile_repo_impl.dart` | The class is still named `XxxRemoteDatasourceImpl` (copy-pasted from the datasource impl), even though the file is `xxx_repo_impl.dart`. Should be `XxxRepoImpl`. |
| `data/models/login/response/token_model.dart` | Class name `TokenData` in a file called `token_model.dart` — mismatch. |
| `data/models/profile/response/profile_reponse_model.dart` | Filename typo (`reponse`, missing an `s`) — the class itself (`ProfileResponseModel`) is spelled correctly. |
| `data/models/login/request/refresh_token_req_param_model.dart` | Plain class, doesn't use `@JsonSerializable` like its sibling `LoginReqParamModel` in the same folder — also has no consumer yet (`ApiPath.URefreshToken` is defined but no datasource calls it). |
| `data/datasources/remote/profile_remote_datasource.dart` | `myProfile()` uses `.post()`, even though it's semantically a GET. |
| `core/error/exception.dart` | `ErrorHandling.handleException()` + the special-cased `NotFoundException` for status 400 — dead code, never called anywhere. |
| `core/http_client/interceptors/custom_interceptor.dart` | The 401/403 auto-logout logic (`onResponse`/`onError`) is entirely commented out — no automatic expired-token handling yet. |
| `core/utils/bloc_providers.dart` | Empty scaffold, never called from `app.dart` — see §7. |
| `test/widget_test.dart` | Still the default Flutter template (counter app `+`/`0`/`1`) — **will fail if run**, doesn't represent this app at all. Replace or delete it before adding other tests. |
| `presentation/pages/login/login_page.dart` | `LoginBloc` is constructed manually (`LoginBloc(getIt<LoginUsecase>(), getIt<ProfileUsecase>())`) even though the class is `@injectable` — could be simplified to `getIt<LoginBloc>()`. |

---

## IMPLICIT RULES SUMMARY

| Rule | Detail |
|---|---|
| Widget = UI only | No business logic in widgets; only `context.read<Bloc>().add(event)` |
| Page → Bloc → Usecase → Repo | A page never calls a repository/datasource directly |
| `toDomain()` lives on the model | Model → entity conversion lives on the model (data layer), not in the repo impl |
| Datasource abstract + impl = 1 file | Not split across separate files |
| 1 usecase file = 1 `execute()` method | Not one class holding many domain methods per feature |
| Errors are always `Either`, never `throw` | `left(Failure)` from the datasource, propagated up to the Bloc |
| Entities must have `.initial()` | Consistent across every entity, including new ones |
| Auth gate lives in `redirect`, not on the page | Don't check the token manually in `initState`/a button handler — update `app_router.dart` |
| Assets via `Assets.xxx.yyy` | Not a raw string path — regenerate with `moshaf_boilerplate assets` |
| Colors/text via `kMain*`/`genStyle()` | Not a literal hex/`TextStyle` directly in a widget |
