import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../Users/UserModel.dart';
import '../Users/UserService.dart';

class SettingsService {
  final UserService _userService = UserService();
  UserModel? _user;

  Future<UserModel?> fetchUser() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _user = await _userService.getUserById(userId);
    }
    return _user;
  }

  Future<void> updateUserData(Map<String, dynamic> updates) async {
    if (_user != null) {
      await _userService.updateUser(_user!.id, updates);
    }
  }

  Future<void> pickAndUploadImage(context, Function(Map<String, dynamic>) onUpload) async {
    if (_user == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();

      // Crear nombre de archivo único con timestamp
      final extension = image.name.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = 'profile_images/${_user!.id}/$timestamp.$extension';

      final storage = Supabase.instance.client.storage.from('UserImage');

      // Subida de imagen (pública)
      final response = await storage.uploadBinary(filePath, bytes, fileOptions: FileOptions(contentType: 'image/$extension'));

      if (response.isNotEmpty) {
        final fileUrl = storage.getPublicUrl(filePath);
        await updateUserData({'photo_url': fileUrl});
        onUpload({'photo_url': fileUrl});
      } else {
        print('❌ Error al subir imagen');
      }
    }
  }

  Future<void> deleteImage(Function(Map<String, dynamic>) onDelete) async {
    if (_user?.photo_url != null) {
      final storage = Supabase.instance.client.storage.from('UserImage');
      final parts = _user!.photo_url!.split('/');
      final filename = parts.sublist(parts.length - 2).join('/'); // path completo dentro del bucket
      final response = await storage.remove([filename]);

      if (response.isEmpty) {
        await updateUserData({'photo_url': null});
        onDelete({'photo_url': null});
      } else {
        print('❌ Error al borrar imagen');
      }
    }
  }
}
