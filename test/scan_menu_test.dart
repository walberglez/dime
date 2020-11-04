import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_options.dart';
import 'package:barcode_scan/model/scan_result.dart';
import 'package:flutter/material.dart';
import 'package:dime/scan_menu.dart';
import 'package:flutter_test/flutter_test.dart';

Widget buildTestableWidget(Widget widget) {
  // https://docs.flutter.io/flutter/widgets/MediaQuery-class.html
  return new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: widget)
  );
}

class BarcodeScannerWrapperMock implements BarcodeScannerWrapper {
  BarcodeScannerWrapperMock({this.scanResult});

  final ScanResult scanResult;

  @override
  Future<int> get numberOfCameras => Future.value(1);

  @override
  Future<ScanResult> scan({ScanOptions options = const ScanOptions()}) => Future.value(scanResult);
}

void main() {
  testWidgets('scan menu: scanned barcode is null, notification is shown', (WidgetTester tester) async {
    BarcodeScannerWrapperMock scannerMock = new BarcodeScannerWrapperMock(scanResult: null);
    // create a ScanMenu
    ScanMenu scanMenu = new ScanMenu(title: 'Test', barcodeScanner: scannerMock,);
    await tester.pumpWidget(buildTestableWidget(scanMenu));
    // scan is called, setState
    await tester.pump();

    final notificationMessageFinder = find.text('Error reading barcode');

    expect(notificationMessageFinder, findsOneWidget);
  });

  testWidgets('scan menu: scanned barcode type is error, notification is shown', (WidgetTester tester) async {
    final scanResult = new ScanResult(type: ResultType.Error);
    BarcodeScannerWrapperMock scannerMock = new BarcodeScannerWrapperMock(scanResult: scanResult);
    // create a ScanMenu
    ScanMenu scanMenu = new ScanMenu(title: 'Test', barcodeScanner: scannerMock,);
    await tester.pumpWidget(buildTestableWidget(scanMenu));
    // scan is called, setState
    await tester.pump();

    final notificationMessageFinder = find.text('Error reading barcode');

    expect(notificationMessageFinder, findsOneWidget);
  });

  testWidgets('scan menu: scanned barcode is not a valid URL, notification is shown', (WidgetTester tester) async {
    final scanResult = new ScanResult(
        type: ResultType.Barcode,
        rawContent: 'http://.',
    );
    BarcodeScannerWrapperMock scannerMock = new BarcodeScannerWrapperMock(scanResult: scanResult);
    // create a ScanMenu
    ScanMenu scanMenu = new ScanMenu(title: 'Test', barcodeScanner: scannerMock,);
    await tester.pumpWidget(buildTestableWidget(scanMenu));
    // scan is called, setState
    await tester.pump();

    final notificationMessageFinder = find.text('Barcode does not contain a valid URL');

    expect(notificationMessageFinder, findsOneWidget);
  });

}