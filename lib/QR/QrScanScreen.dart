import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'QrService.dart';

class QrScanScreen extends StatefulWidget {
  @override
  _QrScanScreenState createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _processing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_processing) return;
      setState(() => _processing = true);

      try {
        final data = jsonDecode(scanData.code ?? '{}');
        final userId = data['userId'];
        final tipo = data['tipo'];
        final monto = double.parse(data['monto'].toString());

        final result = await QrService.procesarTransaccion(userId, tipo, monto);

        _showDialog(result['message'], success: result['success']);
      } catch (e) {
        _showDialog('QR inválido o error de formato.');
      } finally {
        await Future.delayed(Duration(seconds: 2));
        setState(() => _processing = false);
      }
    });
  }

  void _showDialog(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'Éxito' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear QR')),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          if (_processing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
} 