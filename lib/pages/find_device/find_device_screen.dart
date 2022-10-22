import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import '../../widgets.dart';
import '../device_screen/device_screen.dart';
part 'parts/scanning_button.dart';
part 'parts/scan_results.dart';
part 'parts/scan_devices.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await FlutterBlue.instance
              .startScan(timeout: const Duration(seconds: 4));
        },
        child: SingleChildScrollView(
          child: Column(
            children: const <Widget>[
              ScanDevicesList(),
              ScanResultsList(),
            ],
          ),
        ),
      ),
      floatingActionButton: const ScanningButton(),
    );
  }
}
