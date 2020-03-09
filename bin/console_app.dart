import 'dart:io';

import 'package:args/args.dart';
import 'package:console_app/console_app.dart';

/// A mutator function for modifying the behaviour of the application
typedef LineMutator = String Function(String, int);

/// Small container for the definition of a command line flag
class CommandLineFlag {
  final String fullName;
  final String shortName;
  final LineMutator mutator;

  CommandLineFlag(this.fullName, this.shortName, this.mutator);
}

/// A list of command line flags that may modify behavior
/// of the app
final List<CommandLineFlag> ALL_FLAGS = [
  /// Annotate line numbers before each line
  CommandLineFlag(
      'line-numbers', 'n', (String s, int lineNumber) => '${lineNumber} ${s}'),
  CommandLineFlag(
      'all-caps', null, (String s, int lineNumber) => s.toUpperCase()),
];

void main(List<String> argv) {
  // Parse args, which may be a mix of command line params (e.g. --line-number) or
  //  positional arguments (e.g. file names)
  ArgParser argParser = ArgParser();
  // Register our command line flags with the arg parser
  for (CommandLineFlag flag in ALL_FLAGS) {
    argParser.addFlag(flag.fullName, abbr: flag.shortName, negatable: false);
  }
  // Parsing args may fail if the user supplies an unrecognised arg
  ArgResults argResults;
  try {
    argResults = argParser.parse(argv);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 3;
    return;
  }

  // Positional parameters are file paths to cat
  List<String> paths = argResults.rest;

  // Get mutator functions for active flags
  Iterable<LineMutator> activeMutators = ALL_FLAGS
      .where((CommandLineFlag flag) => argResults[flag.fullName])
      .map((CommandLineFlag flag) => flag.mutator);

  // Invoke dcat function
  dcat(paths, activeMutators);
}
