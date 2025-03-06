
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// Copies screenshot to clipboard as PNG image data.
///
/// This implementation is platform-agnostic and works across all platforms
/// supported by the super_clipboard package.
/// The PNG data is copied to the clipboard in its native format,
/// which allows for pasting directly into other applications.
Future<void> screenshotAsImage(
  BuildContext context,
  DeviceScreenshot screenshot,
) async {
  try {
    // Get the clipboard reader/writer
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Clipboard is not available on this platform.'),
        ),
      );
      return;
    }

    final imageData = screenshot.bytes;

    final item = DataWriterItem();

    item.add(Formats.png(imageData));
    await clipboard.write([item]);

  
    if(!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Screenshot copied to clipboard!'),
      ),
    );
  } catch (e) {
    debugPrint('Error copying screenshot to clipboard: $e');
    if(!context.mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error copying screenshot to clipboard: $e'),
      ),
    );
  }
}
