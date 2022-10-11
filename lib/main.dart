import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
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
            if (state == BluetoothState.on) {
              return FindDevicesScreen();
            }
            return BluetoothOffScreen();
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final Duration duration = const Duration(milliseconds: 800);

  const BluetoothOffScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 239, 239),
      body: Container(
        margin: const EdgeInsets.all(8),
        width: size.width,
        height: size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ///
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 2000),
              child: Container(
                margin: const EdgeInsets.only(
                  top: 50,
                  left: 5,
                  right: 5,
                ),
                width: size.width,
                height: size.height / 2,
                child: Lottie.asset("assets/wl.json", animate: true),
              ),
            ),

            ///
            const SizedBox(
              height: 15,
            ),

            /// TITLE

            ///
            const SizedBox(
              height: 10,
            ),

            /// SUBTITLE
            FadeInUp(
              duration: duration,
              delay: const Duration(milliseconds: 1000),
              child: const Text(
                "Please Enable Your BLUETOOTH.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 1.2,
                    color: Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.w300),
              ),
            ),

            ///
            Expanded(child: Container()),

            /// GOOGLE BTN
          ],
        ),
      ),
    );
  }
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2))
                    .asyncMap((_) => FlutterBlue.instance.connectedDevices),
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map((d) => ListTile(
                            title: Text(d.name),
                            subtitle: Text(d.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: d.state,
                              initialData: BluetoothDeviceState.disconnected,
                              builder: (c, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return ElevatedButton(
                                    child: Text('OPEN'),
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
                ),
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data!
                      .map(
                        (r) => ScanResultTile(
                          result: r,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            r.device.connect();
                            return DeviceScreen(device: r.device);
                          })),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () => FlutterBlue.instance
                    .startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}

class DeviceScreen extends StatelessWidget {
  DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  List<int> _getRandomBytes() {
    final listbytes = [
      0xDC,
      0x2E,
      0x20,
      0xF3,
      0x20,
      0x0E,
      0xBF,
      0x0A,
      0x31,
      0x39,
      0x31,
      0xF9,
      0x0F,
      0x31,
      0x5D,
      0xFD,
      0xE4,
      0x19,
      0xB4,
    ];
    List list3 = [];
    for (int i = 0; i < 19; i++) {
      // list3 = (list3[i] ^ list3[i + 1]).toRadixString(16);
      List list4 = [(listbytes[i] ^ listbytes[i + 1])];
      list3 = List.from(list4);
      print(list3);
      //  print('list3: $list3');
    }

    return listbytes;
  }

  Future<List> startLoad() async {
    const textasset = "assets/112936-bluetooth.txt";
    final text = await rootBundle.loadString(textasset);
    final bytes = text.split(',').map((s) => s.trim()).map((s) => int.parse(s));
    final lengthh = bytes.length;
    final listbytes = [
      [206, 49, lengthh]
    ];
    print('ListBytes : $listbytes');
    return listbytes;
  }

  nbrPaquets() async {
    const textasset = "assets/112936-bluetooth.txt";
    final text = await rootBundle.loadString(textasset);
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).length;

    final nbr = [
      [((bytes / 20).ceil())]
    ];
    print('nbr paquets : $nbr');
    return nbr;
  }

  Future<List> localPath() async {
    const textasset = "assets/bytes of led hercules (1).txt";
    final text = await rootBundle.loadString(textasset);
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).toList();

    final chunks = [];
    int chunkSize = 19;
    for (int i = 0; i < bytes.length; i += chunkSize) {
      //  await Future.delayed(Duration(seconds: 1));

      chunks.add(bytes.sublist(
          i, i + chunkSize > bytes.length ? bytes.length : i + chunkSize));
    }

    return chunks;
  }

  bool loading = false;
  double progress = 0;

  int buttonCount = 0;
  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () async =>
                        Future.delayed(Duration(milliseconds: 500), () async {
                      await c.read();
                    }),
                    onWritePressed: () async {
                      buttonCount += 1;

                      final bytes = await startLoad();
                      final chunks = await localPath();
                      final nb = await nbrPaquets();

                      if (buttonCount == 1) {
                        for (List<int> listbytes in bytes) {
                          c.write(listbytes, withoutResponse: true);
                          c.read();
                        }
                      } else if (buttonCount == 2) {
                        for (List<int> paquets in nb) {
                          c.write(paquets, withoutResponse: true);
                          c.read();
                        }
                      } else {
                        await Future.forEach(chunks, (chunk) async {
                          c.write(chunk as List<int>, withoutResponse: true);
                          c.read();
                          await Future.delayed(const Duration(seconds: 4));
                        });
                      }
                    },
                    onSendPressed: () async {
                      final bytes = await startLoad();

                      for (List<int> listbytes in bytes) {
                        c.write(listbytes, withoutResponse: true);
                      }
                    },
                    onSendPaquets: () async {
                      final chunks = await nbrPaquets();

                      for (List<int> chunk in chunks) {
                        c.write(chunk, withoutResponse: true);
                      }
                    },
                    onNotificationPressed: () async {
                      await c.setNotifyValue(!c.isNotifying);
                      Future.delayed(Duration(milliseconds: 500), () async {
                        await c.read();
                      });
                    },
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[
          StreamBuilder<BluetoothDeviceState>(
            stream: device.state,
            initialData: BluetoothDeviceState.connecting,
            builder: (c, snapshot) {
              VoidCallback? onPressed;
              String text;
              switch (snapshot.data) {
                case BluetoothDeviceState.connected:
                  onPressed = () => device.disconnect();
                  text = 'DISCONNECT';
                  break;
                case BluetoothDeviceState.disconnected:
                  onPressed = () => device.connect();
                  text = 'CONNECT';
                  break;
                default:
                  onPressed = null;
                  text = snapshot.data.toString().substring(21).toUpperCase();
                  break;
              }
              return TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .primaryTextTheme
                        .button
                        ?.copyWith(color: Colors.white),
                  ));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
