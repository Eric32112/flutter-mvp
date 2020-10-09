import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart' as picker;

class FilePickerService {
  ImagePicker imagePicker = ImagePicker();

  Future<File> pickImage({@required ImageSource source}) async {
    PickedFile file = await imagePicker.getImage(source: source);
    if (file != null) {
      return File(file.path);
    }
    return null;
  }

  Future<File> pickFile() async {
    return await picker.FilePicker.getFile();
  }

  Future<List<File>> pickFiles() async {
    return await picker.FilePicker.getMultiFile();
  }
}
