import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return File(pickedFile!.path);
  }
}
