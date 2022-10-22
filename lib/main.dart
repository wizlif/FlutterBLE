import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'pages/bluetooth_off_screen.dart';
import 'pages/find_device/find_device_screen.dart';

void main() {
  runApp(const FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            // log(state.toString());
            if (state == BluetoothState.on) {
              FlutterBlue.instance.startScan(
                timeout: const Duration(seconds: 4),
              );
              return const FindDevicesScreen();
            }
            return const BluetoothOffScreen();
          }),
    );
  }
}
