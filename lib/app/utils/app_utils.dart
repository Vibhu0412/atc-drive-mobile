import 'dart:io';

import 'package:atc_drive/app/utils/app_images.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppUtils {
  static Widget getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();

    String assetPath;
    switch (extension) {
      case 'png':
        assetPath = AppImages.icPng;
        break;
      case 'jpg':
      case 'jpeg':
        assetPath = AppImages.icJpg;
        break;
      case 'svg':
        assetPath = AppImages.icSvg;
        break;
      case 'pdf':
        assetPath = AppImages.icPdf;
        break;
      case 'doc':
      case 'docx':
        assetPath = AppImages.icDoc;
        break;
      case 'xls':
      case 'xlsx':
        assetPath = AppImages.icSheet;
        break;
      case 'json':
        assetPath = AppImages.icJson;
        break;
      case 'txt':
        assetPath = AppImages.icTxt;
        break;
      case 'cdr':
        assetPath = AppImages.icCdr;
        break;
      case 'dwg':
        assetPath = AppImages.icDwg;
        break;
      case 'mp4':
      case 'avi':
      case 'mov':
        assetPath = AppImages.icVideo;
        break;
      default:
        assetPath = AppImages.icFile;
    }

    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
    );
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    } else if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }

    return false;
  }
}
