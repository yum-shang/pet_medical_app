import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/common_service.dart';

/// 移动端：POST /api/common/upload
Future<FileUploadResult> uploadAvatarImage(XFile file, CommonService service) {
  return service.uploadFile(File(file.path), bizType: 'avatar');
}
