import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/SettingsService.dart';
import '../Users/UserModel.dart';
import 'Notifications/notifications_servicie.dart';
import 'Notifications/notifications_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final NotificationService _notificationService = NotificationService();
  final SupabaseClient _supabase = Supabase.instance.client;
  UserModel? _user;
  bool _isLoading = true;
  int _unreadNotificationsCount = 0;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchUserData(),
      _fetchUnreadNotificationsCount(),
    ]);
  }

  Future<void> _fetchUserData() async {
    final user = await _settingsService.fetchUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateUserData(Map<String, dynamic> updates) async {
    await _settingsService.updateUserData(updates);
    _fetchUserData();
    
    // Enviar notificación de actualización
    for (final key in updates.keys) {
      await _notificationService.sendProfileUpdateNotification(
        key, 
        updates[key]?.toString()
      );
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    setState(() => _pushNotificationsEnabled = value);
    // Aquí podrías guardar la preferencia en Supabase si lo deseas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        foregroundColor: const Color(0xFFFFD700),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (_user != null) ...[
                  _buildUserProfileSection(),
                  const Divider(),
                  _buildUserInfoSection(),
                  const Divider(),
                ],
                _buildNotificationsSection(),
                const Divider(),
                _buildPreferencesSection(),
              ],
            ),
    );
  }

  Widget _buildUserProfileSection() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _user!.photo_url != null
                  ? NetworkImage(_user!.photo_url!)
                  : null,
              child: _user!.photo_url == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    IconButton(
      icon: const Icon(Icons.add_a_photo),
      onPressed: () => _settingsService.pickAndUploadImage(
        context, 
        (updates) => _updateUserData(updates),
      ),
    ),
    if (_user!.photo_url != null)
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _settingsService.deleteImage(
          (updates) => _updateUserData(updates),
        ),
        iconSize: 20,
      ),
  ],
),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Column(
      children: [
        _buildEditableInfoTile(
          icon: Icons.person,
          label: 'Nombre',
          value: _user!.nombre,
          fieldKey: 'nombre',
        ),
        _buildEditableInfoTile(
          icon: Icons.email,
          label: 'Email',
          value: _user!.email,
          isEditable: false,
        ),
        _buildEditableInfoTile(
          icon: Icons.phone,
          label: 'Teléfono',
          value: _user!.telefono ?? "No especificado",
          fieldKey: 'telefono',
        ),
        _buildEditableInfoTile(
          icon: Icons.home,
          label: 'Dirección',
          value: _user!.direccion ?? "No especificado",
          fieldKey: 'direccion',
        ),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      children: [
        ListTile(
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: Color(0xFFD4AF37)),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: const Text('Notificaciones'),
          subtitle: Text(_unreadNotificationsCount > 0
              ? 'Tienes $_unreadNotificationsCount no leídas'
              : 'No tienes notificaciones nuevas'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            ).then((_) => _fetchUnreadNotificationsCount());
          },
        ),
        
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.bug_report, color: Color(0xFFD4AF37)),
          title: const Text('Probar notificaciones'),
          onTap: () async {
            await _notificationService.sendTestNotification(
              'Notificación de prueba - ${DateTime.now().toString()}'
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notificación de prueba enviada')),
            );
            _fetchUnreadNotificationsCount();
          },
        ),
      ],
    );
  }

  Widget _buildEditableInfoTile({
    required IconData icon,
    required String label,
    required String value,
    String? fieldKey,
    bool isEditable = true,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text('$label: $value'),
      trailing: isEditable
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editField(label, fieldKey!, value),
            )
          : null,
    );
  }

  void _editField(String title, String fieldKey, String? initialValue) {
    final controller = TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Ingrese $title'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Guardar'),
              onPressed: () {
                _updateUserData({fieldKey: controller.text});
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}