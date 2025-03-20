import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:flutter/material.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:web_dex/services/feedback/feedback_service.dart';

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

    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Screenshot copied to clipboard!'),
      ),
    );
  } catch (e) {
    debugPrint('Error copying screenshot to clipboard: $e');
    if (!context.mounted) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error copying screenshot to clipboard: $e'),
      ),
    );
  }
}

/// A button that takes a screenshot and copies it to the clipboard.
///
/// This widget is designed to work with DevicePreview's tools list.
class DevicePreviewScreenshotButton extends StatelessWidget {
  const DevicePreviewScreenshotButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.camera_alt),
      onPressed: () async {
        final screenshot = await DevicePreview.screenshot(context);

        // ignore: use_build_context_synchronously
        await screenshotAsImage(context, screenshot);
      },
    );
  }
}

/// A sliver version of the DevicePreviewScreenshotButton that can be used
/// in scrollable areas that expect sliver widgets.
class DevicePreviewScreenshotButtonSliver extends StatelessWidget {
  const DevicePreviewScreenshotButtonSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text(
            'Screenshot (Copy to clipboard)',
            style: TextStyle(fontSize: 12),
          ),
          dense: true,
          onTap: () async {
            final screenshot = await DevicePreview.screenshot(context);

            // ignore: use_build_context_synchronously
            await screenshotAsImage(context, screenshot);

            ScaffoldMessenger.maybeOf(context)?.showSnackBar(
              const SnackBar(
                content: Text('Screenshot copied to clipboard!'),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A tool to toggle the visibility of the bug report button.
/// Only appears if feedback functionality is available.
class DevicePreviewBugReportToggleSliver extends StatefulWidget {
  const DevicePreviewBugReportToggleSliver({super.key});

  @override
  State<DevicePreviewBugReportToggleSliver> createState() =>
      _DevicePreviewBugReportToggleSliverState();
}

class _DevicePreviewBugReportToggleSliverState
    extends State<DevicePreviewBugReportToggleSliver> {
  bool _showBugReportButton = true;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: !context.isFeedbackAvailable
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: Icon(
                  _showBugReportButton
                      ? Icons.bug_report
                      : Icons.bug_report_outlined,
                ),
                title: const Text(
                  'Toggle Bug Report',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: Switch(
                  value: _showBugReportButton,
                  onChanged: (value) {
                    setState(() {
                      _showBugReportButton = value;
                    });
                    // Notify the app about the bug report visibility change
                    DevicePreviewBugReportNotifier.of(context)
                        ?.updateVisibility(value);
                  },
                ),
                dense: true,
                onTap: () {
                  setState(() {
                    _showBugReportButton = !_showBugReportButton;
                  });
                  // Notify the app about the bug report visibility change
                  DevicePreviewBugReportNotifier.of(context)
                      ?.updateVisibility(_showBugReportButton);
                },
              ),
            ),
    );
  }
}

/// A notifier class to handle bug report button visibility state
class DevicePreviewBugReportNotifier
    extends InheritedNotifier<ValueNotifier<bool>> {
  DevicePreviewBugReportNotifier({
    super.key,
    required super.child,
  }) : super(notifier: ValueNotifier<bool>(true));

  // Update the bug report button visibility
  void updateVisibility(bool visible) {
    notifier!.value = visible;
  }

  // Get the current visibility state
  bool get isVisible => notifier!.value;

  // Find the nearest notifier in the widget tree
  static DevicePreviewBugReportNotifier? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DevicePreviewBugReportNotifier>();
  }
}
