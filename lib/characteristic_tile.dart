import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_blue_example/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart';

class CharacteristicTile extends StatelessWidget {
  final BluetoothCharacteristic characteristic;
  final List<DescriptorTile> descriptorTiles;
  final VoidCallback? onWritePressed;
  final VoidCallback? onSendPressed;
  final VoidCallback? onSendPaquets;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onReadPressed;

  CharacteristicTile(
      {Key? key,
      required this.characteristic,
      required this.descriptorTiles,
      this.onWritePressed,
      this.onSendPressed,
      this.onSendPaquets,
      this.onReadPressed,
      this.onNotificationPressed})
      : super(key: key);
  Widget _buildPopupDialog(BuildContext context) {
    const Color shrineBrown900 = Color(0xFF442B2D);
    /* const snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('Data Sent Successfully '),
      backgroundColor: shrineBrown900,
    );*/

    return new AlertDialog(
      title: const Text('Send data'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            maxLength: 25,
            decoration: const InputDecoration(
                labelText: 'Some Data',
                hintText: 'Entrer du texte',
                border: OutlineInputBorder()),
          )
        ],
      ),
      actions: <Widget>[
        IconButton(
            icon: Icon(
              Icons.send,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onWritePressed),
        IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onSendPressed),
        IconButton(
            icon: Icon(
              Icons.search_off,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            onPressed: onSendPaquets),
      ],
    );
  }

  Future<bool> saveFile(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/RPSApp";
          directory = Directory(newPath);
          print(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await Dio().download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          progress = value1 / value2;
        });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  downloadFile() async {
    loading = true;
    progress = 0;

    bool downloaded = await saveFile(
        "https://gitlab.com/syrinebh004/txtfile/-/raw/txtFile/bytes%20of%20led%20hercules%20(1).txt",
        "assets/bluetooth.txt");
    if (downloaded) {
      print("File Downloaded");
    } else {
      print("Problem Downloading File");
    }
  }

  bool loading = false;
  double progress = 0;

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: characteristic.value,
      initialData: characteristic.lastValue,
      builder: (c, snapshot) {
        final value = snapshot.data;
        return ExpansionTile(
          title: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Characteristic'),
                Text(
                    '0x${characteristic.uuid.toString().toUpperCase().substring(4, 8)}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.caption?.color))
              ],
            ),
            subtitle: Text(value.toString()),
            contentPadding: EdgeInsets.all(0.0),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.send,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onWritePressed,

                //onWritePressed,
              ),
              IconButton(
                icon: Icon(Icons.read_more,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onReadPressed,
              ),
              IconButton(
                icon: Icon(Icons.read_more,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onSendPressed,
              ),
              IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
                color: Colors.blue,
                onPressed: downloadFile,
                padding: const EdgeInsets.all(10),
              ),
              IconButton(
                icon: Icon(
                    characteristic.isNotifying
                        ? Icons.sync_disabled
                        : Icons.sync,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
                onPressed: onNotificationPressed,
              )
            ],
          ),
        );
      },
    );
  }
}
