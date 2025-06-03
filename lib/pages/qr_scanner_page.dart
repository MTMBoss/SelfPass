// lib/pages/qr_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // Gestisce la pausa/resume della camera in fase di hot-reload
  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scansiona QR Code")),
      body: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      if (!mounted) return; // Controlla se il widget è ancora attivo
      Navigator.of(context).pop(scanData.code);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
