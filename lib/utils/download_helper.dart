import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DownloadHelper {
  /// Returns a writable downloads directory path.
  /// On iOS/macOS: ~/Documents/Downloads
  /// On Android:   /storage/emulated/0/Download
  /// On other platforms: User's Downloads directory
  static Future<String> getDownloadPath() async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // Standard Android public downloads folder
      baseDir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      // iOS uses app's Documents directory for writable storage
      baseDir = await getApplicationDocumentsDirectory();
    } else if (Platform.isMacOS) {
      // macOS uses app's Documents directory for writable storage
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      // For other platforms (Windows, Linux), try to get Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        baseDir = downloadsDir;
      } else {
        // Fallback to Documents directory if Downloads is not available
        baseDir = await getApplicationDocumentsDirectory();
      }
    }

    final downloadsDir = Directory(path.join(baseDir.path, 'Downloads'));

    if (!(await downloadsDir.exists())) {
      await downloadsDir.create(recursive: true);
    }

    return downloadsDir.path;
  }

  /// Returns a writable cache directory path.
  /// Uses platform-appropriate cache directories
  static Future<String> getCachePath() async {
    Directory cacheDir;

    if (Platform.isAndroid) {
      // Use external cache directory for Android
      final externalCacheDirs = await getExternalCacheDirectories();
      if (externalCacheDirs != null && externalCacheDirs.isNotEmpty) {
        cacheDir = externalCacheDirs.first;
      } else {
        cacheDir = await getApplicationCacheDirectory();
      }
    } else {
      // For iOS, macOS, and other platforms, use application cache directory
      cacheDir = await getApplicationCacheDirectory();
    }

    final spotubeCacheDir = Directory(path.join(cacheDir.path, 'Spotube'));

    if (!(await spotubeCacheDir.exists())) {
      await spotubeCacheDir.create(recursive: true);
    }

    return spotubeCacheDir.path;
  }
}
