import 'src/flavor/flavor_runner.dart';

/// Also runnable directly (`dart run bin/flavor.dart add <name>`),
/// independent of the `moshaf_boilerplate` CLI entry point.
Future<void> main(List<String> arguments) => mainFlavor(arguments);
