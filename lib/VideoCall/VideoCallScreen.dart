import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// 🔥 TU APP ID de Agora
const String appId = "TU_APP_ID_AQUI";

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  const VideoCallScreen({Key? key, required this.channelName}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final RtcEngine _engine;
  Set<int> _remoteUids = {};
  bool _isEngineReady = false; // 🔥 NUEVA VARIABLE

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appId,
    ));

    await _engine.enableVideo();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("Me uní a la sala: ${connection.channelId}");
          setState(() {}); // Refrescar UI
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("Usuario unido: $remoteUid");
          setState(() {
            _remoteUids.add(remoteUid);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("Usuario fuera: $remoteUid");
          setState(() {
            _remoteUids.remove(remoteUid);
          });
        },
      ),
    );

    await _engine.startPreview();

    await _engine.joinChannel(
      token: '', // 🔥 Modo testing sin token
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    setState(() {
      _isEngineReady = true; // 🔥 Engine inicializado
    });
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sala: ${widget.channelName}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: () {
              Navigator.of(context).pop(); // 🔥 Botón rojo para salir
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildRemoteVideos(),
          Positioned(
            top: 20,
            left: 20,
            child: SizedBox(
              width: 120,
              height: 160,
              child: _buildLocalPreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalPreview() {
    if (!_isEngineReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _buildRemoteVideos() {
    if (!_isEngineReady) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_remoteUids.isEmpty) {
      return const Center(child: Text('Esperando a otros usuarios...'));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: _remoteUids.length,
      itemBuilder: (context, index) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: _engine,
            canvas: VideoCanvas(uid: _remoteUids.elementAt(index)),
            connection: RtcConnection(channelId: widget.channelName),
          ),
        );
      },
    );
  }
}
