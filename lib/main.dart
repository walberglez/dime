import 'package:flutter/material.dart';
import 'scan_menu.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  final title = "DiMe";
  final barcodeScanner = new BarcodeScannerWrapper();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ScanMenu(title: title, barcodeScanner: barcodeScanner),
    );
  }
}