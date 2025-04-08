import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('notificaciones')
          .select()
          .eq('usuario_id', userId)
          .order('fecha', ascending: false);

      setState(() {
        _notifications = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar notificaciones: $e')),
      );
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      setState(() {
        _notifications = _notifications
            .map((n) => n['id'] == id ? {...n, 'leido': true} : n)
            .toList();
      });

      await _supabase
          .from('notificaciones')
          .update({'leido': true}).eq('id', id);
    } catch (e) {
      setState(() {
        _notifications = _notifications
            .map((n) => n['id'] == id ? {...n, 'leido': false} : n)
            .toList();
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      setState(() {
        _notifications =
            _notifications.map((n) => {...n, 'leido': true}).toList();
      });

      await _supabase
          .from('notificaciones')
          .update({'leido': true})
          .eq('usuario_id', userId)
          .eq('leido', false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar como leídas: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFFFFD700),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: _markAllAsRead,
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No tienes notificaciones'))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _NotificationItem(
                        id: notification['id'],
                        message: notification['mensaje'],
                        date: DateTime.parse(notification['fecha']),
                        isRead: notification['leido'],
                        onTap: () => _markAsRead(notification['id']),
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final int id;
  final String message;
  final DateTime date;
  final bool isRead;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.id,
    required this.message,
    required this.date,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isRead ? Colors.grey[100] : const Color(0xFFFFF8E1),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isRead ? Icons.notifications_none : Icons.notifications,
                    color: isRead ? Colors.grey : const Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isRead)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
