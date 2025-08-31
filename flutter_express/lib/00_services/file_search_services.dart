import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_similarity/string_similarity.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<File> copyAssetToTemp(String assetPath) async {
  final byteData = await rootBundle.load(assetPath);
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/${assetPath.split('/').last}');
  await file.writeAsBytes(byteData.buffer.asUint8List());
  return file;
}

class FileSearchService {
  static Future<String?> findBestMatchFile(
      String query, String directoryPath) async {
    try {
      // Ensure directory path ends with a slash
      if (!directoryPath.endsWith('/')) {
        directoryPath += '/';
      }

      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Filter files in the specified directory with extensions
      final files = manifestMap.keys
          .where((String key) => key.startsWith(directoryPath))
          .where((String key) =>
              key.endsWith('.png') ||
              key.endsWith('.jpg') ||
              key.endsWith('.MOV'))
          .toList();

      String? bestMatch;
      double highestSimilarity = 0.5; // Lowered threshold

      for (String filePath in files) {
        // Get filename without extension
        final fileName = filePath
            .split('/')
            .last
            .replaceAll(RegExp(r'\.(png|jpg|MOV)$'), '');

        final similarity =
            fileName.toLowerCase().similarityTo(query.toLowerCase());
        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
          bestMatch = filePath;
        }
      }

      print('Found best match: $bestMatch');
      return bestMatch;
    } catch (e) {
      print('Error in findBestMatchFile: $e');
      return null;
    }
  }
}
