part of '../find_device_screen.dart';

class ScanDevicesList extends StatelessWidget {
  const ScanDevicesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: Stream.periodic(const Duration(seconds: 2))
          .asyncMap((_) => FlutterBlue.instance.connectedDevices),
      initialData: const [],
      builder: (c, snapshot) {
        final devices = snapshot.data ?? [];
        // log(devices.toString());
        return Column(
          children: devices
              .map((d) => ListTile(
                    title: Text(d.name),
                    subtitle: Text(d.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: d.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data == BluetoothDeviceState.connected) {
                          return ElevatedButton(
                            child: const Text('OPEN'),
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DeviceScreen(device: d))),
                          );
                        }
                        return Text(snapshot.data.toString());
                      },
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
