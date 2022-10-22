import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils.dart';
import '../../widgets.dart';

part 'parts/bluetooth_device_mtu.dart';
part 'parts/bluetooth_device_state.dart';
part 'parts/bluetooth_service_list.dart';
part 'parts/bluetooth_toggle_button.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[BluetoothToggleButton(device: device)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            BluetoothDeviceStateHandler(device: device),
            BluetoothDeviceMtu(device: device),
            BluetoothServiceList(device: device),
          ],
        ),
      ),
    );
  }
}
