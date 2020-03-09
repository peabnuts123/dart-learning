import 'dart:convert';
import 'dart:io';

import 'package:console_app/src/console_app/types/line_mutator.dart';

/// Print out the contents of a list of paths
Future dcat(List<String> paths, Iterable<LineMutator> lineMutators) async {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    await stdin.pipe(stdout);
  } else {
    for (String path in paths) {
      // Read file into array of line strings
      final lines = utf8.decoder
          .bind(File(path).openRead())
          .transform(const LineSplitter());

      try {
        // Iterate through each line
        int lineNumber = 1;
        await for (String line in lines) {
          // Run any active mutators
          String mutatedLine = line;
          for (LineMutator mutator in lineMutators) {
            mutatedLine = mutator(mutatedLine, lineNumber++);
          }

          // Print mutated string
          stdout.writeln(mutatedLine);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln("Error: '${path}' is a directory");
  } else {
    exitCode = 2;
  }
}
