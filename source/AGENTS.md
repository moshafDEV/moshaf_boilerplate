# AGENTS.md — working rules for AI agents in ProjectDisplayName

Applies to every agent (Claude Code, Cursor, Codex, ...) and to every change, however small. If a request conflicts with these rules, say so before writing code.

## 0. Source of truth

1. [PROJECT_BLUEPRINT.md](./PROJECT_BLUEPRINT.md) is this project's code standard. **Read it before writing code.**
2. Existing code is the living example. Before creating a file, find a similar feature and copy its pattern (auth/login is the reference one).
3. Patterns listed in blueprint §13 (known inconsistencies) are documented as-is — **do not copy them**.
4. Deviating from the blueprint needs a clear reason and a note in the same change (add a row to the blueprint, or update the section that no longer holds).

## 1. Adding or changing a feature

Work bottom-up. A layer never skips another layer.

```
ApiPath → Model (request/response) → Datasource → Repository (abstract + impl)
        → Entity → Usecase → Bloc (freezed event/state) → Page + components
```

- **Datasource**: abstract + `@LazySingleton(as:)` impl in one file. Catches `DioException` inside each method and returns `left(Failure)`. Never throws to the caller.
- **Model**: only models know the API format. Response: `fromJson` + `toDomain()`. Request: `fromDomain()` + `toJson()`.
- **Repo impl** (`data/repository_impls/`, class `XxxRepoImpl`): no JSON parsing; wrap `toDomain()` in try/catch and map it to a `Failure`.
- **Entity**: `@freezed`, must have `.initial()`, no JSON.
- **Usecase**: one file, one class, one `execute()` returning `Future<Either<Failure, T>>`.
- **Bloc**: `@injectable`, `Event`/`State` as `part` files, state flat (`isLoading`, `errorResponseMessage`, `success*`). Reset error and `success*` at the start of each handler; wrap the usecase call in try/catch so `isLoading` can't get stuck.
- **Page**: never calls a repository/datasource/usecase and never builds a `Dio()` — everything goes through a bloc. Provide the bloc with `BlocProvider(create: (_) => getIt<XxxBloc>())`; go global (`core/utils/bloc_providers.dart`) only when something outside the page needs it (blueprint §7).
- **Routes**: add paths to `Paths`, register in `app_router.dart`. Auth gating lives in `redirect`, not in pages.

## 2. UI & performance rules

- Text: `genStyle(...)` / `genStyleNN*` from `core/constants/textstyle.dart`. No new `TextStyle(` in widgets.
- Colors: `kMain*` constants from `core/constants/colors.dart`. No literal `Color(0x...)` in widgets — add a token instead.
- Route paths only from `Paths`; assets only through `Assets.*` (run `moshaf_boilerplate assets` after adding/removing files under `assets/`).
- Reuse `presentation/components/` (button, dialog_popup, snackbar_widget, bottomsheet_manager, text_field_custom_widget, ...) before building a new widget.
- `setState` only for cheap, local UI state (toggle, tab index, expand, small animation). Never for server/async data or to mirror bloc state.
- Read bloc state with `context.select`/`BlocSelector` for fields that change often, not `context.watch`. Other `BlocBuilder`/`BlocConsumer`s get `buildWhen`/`listenWhen`.
- One-shot effects (navigate, snackbar) use a `success*` flag reset at the start of the next handler.
- One public widget per file, aim for ≤ ~300 lines. No `*_widgets.dart` grab-bags, no new `Widget _buildX()` methods. Non-widget logic doesn't belong in `pages/`.

## 3. Code style

- Comments: English, short, only for what the code can't say (why, limits, traps). No explaining standard syntax.
- User-facing strings in English unless the project uses `easy_localization` keys for them.
- Follow naming and idioms of the surrounding files. Don't add abstractions nobody needs yet.
- **Adding a dependency to `pubspec.yaml` needs the user's approval first.**
- Never hardcode secrets or real URLs. Config goes through `.env.<flavor>` + `core/env/env.dart`; the committed `.env.*` files hold placeholders only.

## 4. Before you say "done"

Flutter runs through FVM when `.fvmrc` exists (`fvm flutter` / `fvm dart`), otherwise plain `flutter`/`dart`.

```bash
moshaf_boilerplate env <flavor>           # only when switching flavor / editing .env.*
dart run build_runner build -d            # after touching freezed/json/injectable/envied
dart format lib test
flutter analyze                           # must be "No issues found!"
flutter test                              # must pass
```

- Generated files (`*.freezed.dart`, `*.g.dart`, `*.config.dart`) and `.env` are git-ignored: run `build_runner` after cloning or switching branches; don't hand-edit or commit them.
- New logic (entity, bloc, redirect, formatter, masking) comes with a test under `test/` mirroring `lib/`. `mocktail` is available.
- Report honestly: if something couldn't be verified (needs a device, signing, a backend), say so.
- Don't commit, push, or amend unless the user asked.

## 5. Documentation

- Don't add `.md` files for plans, notes, or checklists — put the plan in chat or the PR description.
- Kept docs: `README.md`, `PROJECT_BLUEPRINT.md`, `AGENTS.md`, `ci/docs/`, `docs/release/`.
- Changing a pattern or standard means updating `PROJECT_BLUEPRINT.md` in the same change.
- The Mermaid diagrams in `README.md` (quick start, request flow) and `PROJECT_BLUEPRINT.md` (§6 routing) mirror real code. If you change that flow, update its diagram in the same change.

## 6. Project tooling (don't reinvent)

- `moshaf_boilerplate env [flavor]` — copies `.env.<flavor>` to `.env` (+ Firebase plist), optionally runs `build_runner`. (`pre_launch_task` is its deprecated old name.)
- `moshaf_boilerplate build [apk|aab|ipa] [flavor]` — env step + `flutter build` with the right `--flavor`/`-t`. `--bump`/`--save` edit the `version:` line in `pubspec.yaml`.
- `moshaf_boilerplate flavor add <name>` — scaffolds a flavor; native regen (`dart run flutter_flavorizr -f`) stays a deliberate manual step. Don't hand-edit generated native flavor config.
- `moshaf_boilerplate assets` — regenerates `assets.gen.dart`.

## 7. Known traps

- `MainClient` uses `DioMixin`, so `download()` isn't implemented (throws `UnimplementedError`). Fetch bytes with `get<List<int>>` + `ResponseType.bytes` and write the file yourself.
- Don't use `identical()` on `List`/`Map` fields of freezed state: the getter wraps the collection in a new unmodifiable view on every access, so it's always false. Use a version counter in the bloc to detect replaced data.
- Developer Tools screens are pushed with `pushDeveloperPage()` onto the root navigator — never register them as `go_router` routes (blueprint §11). `ApiLoggerInterceptor` must keep masking sensitive keys; extend `_sensitiveBodyKeys` when the API adds new secret fields.
- Feature flags: add a field once to the module entity's `fromJson`/`toJson`; the Developer Tools screen and its "copy expected response" button derive from it (blueprint §12). Failures must fall back to flags-off, never crash.
- `dev` and `staging` share one applicationId/bundleId on purpose — they can't be installed side by side (blueprint §10).
- Edit `Info.plist` only at the root `<dict>` and check with `plutil -lint`; a key inside a nested dict can crash the app on launch.
- Changing `compileSdk` in `android/app/build.gradle.kts` below 37 breaks `flutter_secure_storage`; leave the `maxOf(..., 37)` floor alone.
