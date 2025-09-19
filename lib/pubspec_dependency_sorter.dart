import 'dart:io';
import 'package:pubspec/pubspec.dart';
import 'package:yaml_writer/yaml_writer.dart';

pubspecDependencySorter({required List<String> args}) async {
  try {
    String path = args.isEmpty ? Directory.current.path : args[0];
    Directory myDirectory = Directory(path);

    // Load the pubspec.yaml file
    var pubSpec = await PubSpec.load(myDirectory);

    // Sort dependencies, devDependencies, and dependencyOverrides
    var sortedDependencies = _sortDependencies(pubSpec.dependencies);
    var sortedDevDependencies = _sortDependencies(pubSpec.devDependencies);
    var sortedDependencyOverrides = _sortDependencies(pubSpec.dependencyOverrides);

    // Create a new PubSpec with sorted dependencies
    var newPubSpec = pubSpec.copy(
      dependencies: sortedDependencies,
      devDependencies: sortedDevDependencies,
      dependencyOverrides: sortedDependencyOverrides,
    );

    // Write the sorted dependencies back to pubspec.yaml
    var yamlWriter = YamlWriter(allowUnquotedStrings: true);
    var yamlDoc = yamlWriter.write(newPubSpec.toJson());

    // Format the YAML document (without adding a blank line at the top)
    var formattedYamlDoc = _formatYamlWithSpaces(yamlDoc);

    // Save the formatted YAML to the file
    File file = File("${myDirectory.path}/pubspec.yaml");
    await file.writeAsString(formattedYamlDoc);
  } catch (e) {
    print('Error: $e'); // Simplified error handling
  }
}

Map<String, DependencyReference> _sortDependencies(
    Map<String, DependencyReference> dependencies) {
  var sortedKeys = dependencies.keys.toList()..sort();
  return Map.fromEntries(sortedKeys.map((key) => MapEntry(key, dependencies[key]!)));
}

String _formatYamlWithSpaces(String yamlDoc) {
  var lines = yamlDoc.split('\n');
  var formattedLines = <String>[];

  for (var line in lines) {
    // Add a blank line before top-level keys (except the first one)
    if (line.isNotEmpty && !line.startsWith(' ') && formattedLines.isNotEmpty) {
      formattedLines.add('');
    }
    formattedLines.add(line);
  }

  return formattedLines.join('\n');
}
