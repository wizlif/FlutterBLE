part of '../device_screen.dart';

class BluetoothDeviceMtu extends StatelessWidget {
  final BluetoothDevice device;
  const BluetoothDeviceMtu({Key? key,required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: const Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            );
  }
}
