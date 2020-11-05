import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart';
import 'package:validators/validators.dart' as validators;

class ScanMenu extends StatefulWidget {
  ScanMenu({Key key, this.title, this.barcodeScanner}) : super(key: key);

  final String title;
  final BarcodeScannerWrapper barcodeScanner;

  @override
  _ScanMenuState createState() => _ScanMenuState();
}

class _ScanMenuState extends State<ScanMenu> {
  final _flashOnController = TextEditingController(text: "Flash ON");
  final _flashOffController = TextEditingController(text: "Flash OFF");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  @override
  initState() {
    super.initState();

    scan();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/scan.png'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 17.0, vertical: 17.0),
                child: RaisedButton(
                    color: Colors.green,
                    textColor: Colors.white,
                    splashColor: Colors.blueGrey,
                    onPressed: scan,
                    child: const Text(
                      'SCAN MENU',
                      style: TextStyle(fontFamily: 'Fira Sans', fontSize: 40),
                    )),
              ),
            ],
          ),
        ),
      );
  }

  void scan() async {
    var options = ScanOptions(
      strings: {
        "cancel": _cancelController.text,
        "flash_on": _flashOnController.text,
        "flash_off": _flashOffController.text,
      },
      useCamera: _selectedCamera,
      autoEnableFlash: _autoEnableFlash,
      android: AndroidOptions(
        aspectTolerance: _aspectTolerance,
        useAutoFocus: _useAutoFocus,
      ),
    );

    try {
      var result = await widget.barcodeScanner.scan(options: options);
      process(result);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        return;
      }

      showNotification("Unknown error reading barcode: $e");
    }
  }

  void process(ScanResult barcode) {
    // make sure barcode is valid
    if (barcode == null || barcode.type == ResultType.Error) {
      showNotification("Error reading barcode");
      return;
    }

    if (barcode.type == ResultType.Cancelled) {
      return;
    }

    var rawBarcode = barcode.rawContent;

    if (!validators.isURL(rawBarcode, requireTld: false)) {
      showNotification("Barcode does not contain a valid URL");
      return;
    }

    // TODO: get content type of URL

    // TODO: redirect to supported menu parser
  }

  void showNotification(String message) {
    final notification = SnackBar(
      content: Text(
        message,
        style: new TextStyle(
            fontFamily: 'Fira Sans',
            fontSize: 18.0,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(notification);
  }
}

class BarcodeScannerWrapper {
  Future<int> get numberOfCameras => BarcodeScanner.numberOfCameras;
  Future<ScanResult> scan({ScanOptions options = const ScanOptions()}) => BarcodeScanner.scan(options: options);
}