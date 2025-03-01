import 'dart:developer';

import 'package:path/path.dart' as p;

List<String> pathConv(String path) {
  try {
    String normalizedPath = p.normalize(path);

    if (normalizedPath.isEmpty || normalizedPath == '.') {
      return [];
    }

    if (normalizedPath == '/' || normalizedPath == '\\') {
      return ['/'];
    }

    return normalizedPath
        .replaceAll('\\', '/')
        .split('/')
        .where((element) => element.isNotEmpty)
        .toList();
  } on FormatException catch (e) {
    log("Error decoding: $e");
    return [];
  }
}
