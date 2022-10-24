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

                // final isNotifyingXtic42 =
                //     c.isNotifying && c.uuid.toByteArray() == [170, 34];

                final isNotifyingXtic42 =
                    c.isNotifying && c.uuid.toString() == characteristic42Uuid;

                log("NOTIFYING CHARACTERISTIC 42: $isNotifyingXtic42");
                
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

const characteristic42Uuid = "0000fe42-8e22-4541-9d4c-21edae82ed19";
