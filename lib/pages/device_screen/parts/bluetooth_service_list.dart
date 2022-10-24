part of '../device_screen.dart';

class BluetoothServiceList extends StatelessWidget {
  final BluetoothDevice device;
  const BluetoothServiceList({Key? key, required this.device})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothService>>(
      stream: device.services,
      initialData: const [],
      builder: (c, snapshot) {
        final services = snapshot.data ?? [];

        return Column(
          children: _buildServiceTiles(services),
        );
      },
    );
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics.map(
              (c) {
                log("#### CHARACTERISTIC #####");
                log("DEVICE_ID: ${c.deviceId.id}");
                log("SERVICE_UUID: ${c.serviceUuid.toByteArray()}");
                log("CHARACTERISTIC UUID: ${c.uuid.toByteArray()}");
                log("NOTIFYING: ${c.isNotifying}");
                return CharacteristicTile(
                  characteristic: c,
                  onReadPressed: () async => {
                    // Future.delayed(Duration(milliseconds: 500), () async {
                    await c.read()
                  },
                  onWritePressed: () => _onWritePressed(c),
                  //this for enabling notification
                  onNotificationPressed: () async {
                    await c.setNotifyValue(!c.isNotifying);
                    Future.delayed(const Duration(milliseconds: 500), () async {
                      //this is for reading the value of the notification

                      await c.read();
                    });
                  },
                  descriptorTiles: c.descriptors
                      .map(
                        (d) => DescriptorTile(
                          descriptor: d,
                          onReadPressed: () => d.read(),
                        ),
                      )
                      .toList(),
                );
              },
            ).toList(),
          ),
        )
        .toList();
  }

  Future<void> _onWritePressed(BluetoothCharacteristic c) async {
    final chunks = await Utils.localPath();

    await Future.forEach(chunks, (chunk) async {
      if (c.isNotifying) {
        c.write(chunk as List<int>, withoutResponse: true);
        await c.read();
        await Future.delayed(const Duration(seconds: 4));
      }
    });
  }
}
