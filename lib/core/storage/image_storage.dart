import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Copies gallery images into app storage for stable offline paths.
class ImageStorage {
  Future<String?> persistGalleryImage(XFile? file) async {
    if (file == null) return null;
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'food_images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final ext = p.extension(file.path);
    final name = '${Uuid().v4()}$ext';
    final destPath = p.join(dir.path, name);
    final bytes = await file.readAsBytes();
    await File(destPath).writeAsBytes(bytes, flush: true);
    return destPath;
  }

  Future<void> deleteIfExists(String? path) async {
    if (path == null || path.isEmpty) return;
    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}
