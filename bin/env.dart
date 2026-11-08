import 'src/pre_launch/pre_launch_runner.dart';

/// Also runnable directly (`dart run bin/env.dart <flavor>`), independent of
/// the `moshaf_boilerplate` CLI entry point.
Future<void> main(List<String> arguments) => mainEnv(arguments);
