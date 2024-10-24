import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrious/utils/logger.dart';

mixin UiInfoMixin {
  showSnackMessage(BuildContext context, String message,
      {Duration duration = const Duration(milliseconds: 1000)}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
      behavior: Platform.isIOS ? null :  SnackBarBehavior.floating,
      margin: Platform.isIOS ? null :  const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: duration,
    ));
  }
}

mixin ImageMixin {
  ImagePicker imagePicker = ImagePicker();

  Future<XFile?> getSingleImageFromSource(
      {ImageSource source = ImageSource.gallery}) async {
    XFile? image =
        await imagePicker.pickImage(source: source, imageQuality: 80);

    log.i("Image: $image");

    return image;
  }

  Future<CroppedFile?> cropImage(BuildContext context, XFile imageFile) {
    return ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Theme.of(context).colorScheme.primaryContainer,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          showCancelConfirmationDialog: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
  }
}
