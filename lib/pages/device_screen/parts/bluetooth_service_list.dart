part of '../device_screen.dart';

class BluetoothServiceList extends StatefulWidget {
  final BluetoothDevice device;
  const BluetoothServiceList({Key? key, required this.device})
      : super(key: key);

  @override
  State<BluetoothServiceList> createState() => _BluetoothServiceListState();
}

class _BluetoothServiceListState extends State<BluetoothServiceList> {
  bool _isNotifying = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BluetoothService>>(
      stream: widget.device.services,
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

                // Set notifying to enabled
                // when c.isNotifying && is characteristic 49
                if (c.isNotifying && c.isCharacteristic49) {
                  _isNotifying = true;
                }

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

  /// Write chunks if is characteristic 42
  /// and [_isNotifying] is true
  Future<void> _onWritePressed(BluetoothCharacteristic c) async {
    if (c.isCharacteristic42 && _isNotifying) {
      final chunks = await Utils.localPath();

      await Future.forEach(chunks, (chunk) async {
        c.write(chunk as List<int>, withoutResponse: true);
        await c.read();
        await Future.delayed(const Duration(seconds: 4));
      });
    }
  }
}

extension CharacteristicX on BluetoothCharacteristic {
  bool get isCharacteristic42 => uuid.toString() == characteristic42Uuid;
  bool get isCharacteristic49 => uuid.toByteArray() == characteristic49Uuid;
}

const characteristic42Uuid = "0000fe42-8e22-4541-9d4c-21edae82ed19";
const characteristic49Uuid = [
  0,
  0,
  254,
  66,
  142,
  34,
  69,
  65,
  157,
  76,
  33,
  237,
  174,
  130,
  237,
  25
];
