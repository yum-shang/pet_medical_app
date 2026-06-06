import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/common_service.dart';

import 'upload_avatar_stub.dart'
    if (dart.library.io) 'upload_avatar_io.dart' as impl;

Future<FileUploadResult> uploadAvatarImage(XFile file, CommonService service) {
  return impl.uploadAvatarImage(file, service);
}
