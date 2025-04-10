import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../services/ChatService.dart';
import 'theme_notifier.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  File? _image;
  int? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    userId = user!.id;
    userName = user.email ?? 'Usuario';
  }

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty || _image != null) {
      String? imageUrl;

      if (_image != null) {
        imageUrl = await _chatService.uploadImage(_image!, userId);
      }

      await _chatService.sendMessage(userId, userName, _controller.text.trim(), imageUrl: imageUrl);

      _controller.clear();
      _image = null;
      _scrollToBottom();
      setState(() {
        _isTyping = false;
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

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _onLongPressMessage(int messageId) {
    setState(() {
      _selectedMessageId = messageId;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Qué te gustaría hacer?'),
          actions: [
            TextButton(
              onPressed: () {
                _editMessage(messageId);
                Navigator.pop(context);
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () {
                _deleteMessage(messageId);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _editMessage(int messageId) {
    // Aquí puedes abrir un modal para editar el mensaje y actualizarlo en Supabase
    print('Editar mensaje con ID: $messageId');
  }

  void _deleteMessage(int messageId) async {
    await _chatService.deleteMessage(messageId);
    setState(() {
      _selectedMessageId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mensaje eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

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

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['usuario_id'] == userId;

                    return GestureDetector(
                      onLongPress: () => _onLongPressMessage(message['id']),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMe)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[400],
                                  child: Text(
                                    message['nombre_usuario']?.substring(0, 1).toUpperCase() ?? '?',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.amber[600] : Colors.grey[200],
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(12),
                                    topRight: const Radius.circular(12),
                                    bottomLeft: Radius.circular(isMe ? 12 : 0),
                                    bottomRight: Radius.circular(isMe ? 0 : 12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          message['nombre_usuario'] ?? 'Anónimo',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      message['contenido'] ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (message['imagen_url'] != null && message['imagen_url'] != '')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(message['imagen_url']),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMe)
                              const SizedBox(width: 8),
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
                        _isTyping = text.isNotEmpty;
                      });
                    },
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, size: 30, color: Colors.black),
                      onPressed: _takePicture,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.amber),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}