import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:web_dex/services/file_loader/file_loader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileLoaderNativeIOS implements FileLoader {
  const FileLoaderNativeIOS();

  @override
  Future<void> save({
    required String fileName,
    required String data,
    LoadFileType type = LoadFileType.text,
  }) async {
    switch (type) {
      case LoadFileType.text:
        await _saveAsTextFile(fileName: fileName, data: data);
        break;
      case LoadFileType.compressed:
        await _saveAsCompressedFile(fileName: fileName, data: data);
        break;
    }
  }

  Future<void> _saveAsTextFile({
    required String fileName,
    required String data,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, '$fileName.txt');
    final File file = File(filePath);
    await file.writeAsString(data);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _saveAsCompressedFile({
    required String fileName,
    required String data,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = path.join(directory.path, '$fileName.zip');

    final List<int> fileBytes = utf8.encode(data);

    // Using ZLibCodec for compression
    final compressedBytes = ZLibEncoder().convert(fileBytes);

    final File compressedFile = File(filePath);
    await compressedFile.writeAsBytes(compressedBytes);

    await Share.shareXFiles([XFile(compressedFile.path)]);
  }

  @override
  Future<void> upload({
    required Function(String name, String content) onUpload,
    required Function(String) onError,
    LoadFileType? fileType,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: fileType == null ? FileType.any : fileType.fileType,
        allowedExtensions: fileType != null ? [fileType.extension] : null,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null) return;

      final selectedFile = File(path);
      final data = await selectedFile.readAsString();

      onUpload(file.name, data);
    } catch (e) {
      onError(e.toString());
    }
  }
}
