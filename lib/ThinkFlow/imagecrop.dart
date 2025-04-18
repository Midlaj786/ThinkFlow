import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

Future<File?> cropImage(File imageFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.orange,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Crop Image',
        minimumAspectRatio: 1.0,
      ),
    ],
  );

  if (croppedFile != null) {
    return File(croppedFile.path); // Convert CroppedFile to File
  }
  return null;
}
