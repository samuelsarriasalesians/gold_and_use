import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/ChatService.dart';
import 'theme_notifier.dart'; // Para obtener el modo de tema
import 'package:provider/provider.dart'; // Import the Provider package


class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  late final String userId;
  late final String userName;
  final ScrollController _scrollController = ScrollController(); // Para bajar al final
  bool _isTyping = false; // Estado para saber si el usuario está escribiendo

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    userId = user!.id;
    userName = user.email ?? 'Usuario';
  }

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      await _chatService.sendMessage(userId, userName, _controller.text.trim());
      _controller.clear();
      _scrollToBottom(); // Baja al último mensaje
      setState(() {
        _isTyping = false; // Deja de escribir
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context); // Obtener el tema actual

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Global'),
        backgroundColor: themeNotifier.value == ThemeMode.dark
            ? Colors.black
            : const Color(0xFFFFD700),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['usuario_id'] == userId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.amber[600] : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Text(
                                message['nombre_usuario'] ?? 'Anónimo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: themeNotifier.value == ThemeMode.dark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                            Text(
                              message['contenido'] ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _isTyping
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.keyboard, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Escribiendo...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (text) {
                      setState(() {
                        _isTyping = text.isNotEmpty; // Detecta si el usuario está escribiendo
                      });
                    },
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
