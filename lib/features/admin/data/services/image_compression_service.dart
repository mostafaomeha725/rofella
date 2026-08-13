import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {
  /// Compresses the given [imageBytes] if it exceeds 500 KB.
  /// 
  /// Returns the original [imageBytes] if it's under 500 KB or if compression fails.
  /// Ensures no UI freezing by running asynchronously, and safely supports Web/iOS/Android.
  Future<Uint8List> compress(Uint8List imageBytes) async {
    final originalSizeKb = imageBytes.lengthInBytes / 1024;

    // Compress ONLY if image size > 150 KB to avoid over-compressing tiny icons.
    if (originalSizeKb <= 150) {
      if (kDebugMode) {
        print('Original size (KB): ${originalSizeKb.toStringAsFixed(2)}');
        print('Compression skipped (true)');
        print('Platform: ${defaultTargetPlatform.name}');
      }
      return imageBytes;
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Compress with 1000x1000 constraints, 80% quality, and WebP format
      final compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 1000,
        minHeight: 1000,
        quality: 80,
        format: CompressFormat.webp,
        keepExif: false, // Discard EXIF to save space
      );

      stopwatch.stop();

      final compressedSizeKb = compressedBytes.lengthInBytes / 1024;
      final ratio = ((originalSizeKb - compressedSizeKb) / originalSizeKb) * 100;

      if (kDebugMode) {
        print('Original size (KB): ${originalSizeKb.toStringAsFixed(2)}');
        print('Compressed size (KB): ${compressedSizeKb.toStringAsFixed(2)}');
        print('Compression ratio (%): ${ratio.toStringAsFixed(2)}');
        print('Compression time (ms): ${stopwatch.elapsedMilliseconds}');
        print('Platform: ${defaultTargetPlatform.name}');
        print('Compression skipped (false)');
      }

      return compressedBytes;
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print('Image compression failed: $e');
        print('Warning: Uploading original image as fallback.');
      }
      return imageBytes;
    }
  }
}
