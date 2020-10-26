import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiMe',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ScanMenu(title: 'DiMe'),
    );
  }
}

class ScanMenu extends StatefulWidget {
  ScanMenu({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScanMenuState createState() => _ScanMenuState();
}

class _ScanMenuState extends State<ScanMenu> {
  ScanResult barcode;

  final _flashOnController = TextEditingController(text: "Flash ON");
  final _flashOffController = TextEditingController(text: "Flash OFF");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  @override
  initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;

      scan();

      setState(() {});
    });
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
            Text(barcode != null && barcode.type == ResultType.Barcode ? barcode.rawContent : ""),
          ],
        ),
      ),
    );
  }

  Future scan() async {
    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        //restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      var result = await BarcodeScanner.scan(options: options);

      setState(() => barcode = result);
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        return;
      }

      result.rawContent = 'Unknown error: $e';

      setState(() {
        barcode = result;
      });
    }
  }
}
