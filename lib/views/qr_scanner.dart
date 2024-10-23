import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  bool qrDetected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.qrScannerTitle.tr()),
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
        elevation: 0,
      ),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionTimeoutMs: 1000,
          formats: [BarcodeFormat.qrCode],
        ),
        errorBuilder: _buildQrScannerError,
        onDetect: (capture) {
          if (qrDetected) return;

          final List<Barcode> qrCodes = capture.barcodes;

          if (qrCodes.isNotEmpty) {
            final r = qrCodes.first.rawValue;
            qrDetected = true;

            // MRC: Guarantee that we don't try to close the current screen
            // if it was already closed
            if (!context.mounted) return;
            Navigator.pop(context, r);
          }
        },
        placeholderBuilder: (context, _) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildQrScannerError(
      BuildContext context, MobileScannerException exception, _) {
    late String errorMessage;

    switch (exception.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = LocaleKeys.qrScannerErrorControllerUninitialized.tr();
        break;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = LocaleKeys.qrScannerErrorPermissionDenied.tr();
        break;
      case MobileScannerErrorCode.genericError:
      default:
        errorMessage = LocaleKeys.qrScannerErrorGenericError.tr();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.yellowAccent,
            size: 64,
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.qrScannerErrorTitle.tr(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          Text(errorMessage, style: Theme.of(context).textTheme.bodyLarge),
          if (exception.errorDetails != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '${LocaleKeys.errorCode.tr()}: ${exception.errorDetails!.code}'),
                Text(
                    '${LocaleKeys.errorDetails.tr()}: ${exception.errorDetails!.details}'),
                Text(
                    '${LocaleKeys.errorMessage.tr()}: ${exception.errorDetails!.message}'),
              ],
            ),
        ],
      ),
    );
  }
}
