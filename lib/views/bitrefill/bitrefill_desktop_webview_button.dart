import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/bitrefill/bloc/bitrefill_bloc.dart';
import 'package:web_dex/views/bitrefill/bitrefill_button_view.dart';

/// A button that opens the provided [url] in a Browser window on Desktop platforms.
/// This widget uses the desktop_webview_window package to open a new window.
/// The window is closed when a BitrefillPaymentInProgress event is received.
///
/// NOTE: this widget only works on Windows, Linux and macOS
class BitrefillDesktopWebviewButton extends StatefulWidget {
  /// The [onMessage] callback is called when a message is received from the webview.
  /// The [enabled] property determines if the button is enabled.
  /// The [windowTitle] property is used as the title of the window.
  /// The [url] property is the URL to open in the window.
  const BitrefillDesktopWebviewButton({
    super.key,
    required this.url,
    required this.windowTitle,
    required this.enabled,
    required this.onMessage,
  });

  /// The title of the pop-up browser window.
  final String windowTitle;

  /// The URL to open in the pop-up browser window.
  final String url;

  /// Determines if the button is enabled.
  final bool enabled;

  /// The callback function that is called when a message is received from the webview.
  final dynamic Function(String) onMessage;

  @override
  BitrefillDesktopWebviewButtonState createState() =>
      BitrefillDesktopWebviewButtonState();
}

class BitrefillDesktopWebviewButtonState
    extends State<BitrefillDesktopWebviewButton> {
  Webview? webview;

  @override
  Widget build(BuildContext context) {
    return BlocListener<BitrefillBloc, BitrefillState>(
      listener: (BuildContext context, BitrefillState state) {
        if (state is BitrefillPaymentInProgress) {
          webview?.close();
        }
      },
      child: BitrefillButtonView(
        onPressed: widget.enabled ? _openWebview : null,
      ),
    );
  }

  void _openWebview() {
    WebviewWindow.isWebviewAvailable().then((bool value) {
      _createWebview();
    });
  }

  Future<void> _createWebview() async {
    webview?.close();
    webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        title: widget.windowTitle,
        titleBarTopPadding: Platform.isMacOS ? 20 : 0,
      ),
    );
    webview
      ?..registerJavaScriptMessageHandler('test', (String name, dynamic body) {
        widget.onMessage(body as String);
      })
      ..addOnWebMessageReceivedCallback(
        (String body) => widget.onMessage(body),
      )
      ..setApplicationNameForUserAgent(' WebviewExample/1.0.0')
      ..launch(widget.url);
  }
}
