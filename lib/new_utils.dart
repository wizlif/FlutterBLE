import 'dart:io';

import 'package:flutter/services.dart';

class Utils {
  static Future<List> localPath() async {
    File textasset = File('/storage/emulated/0/RPSApp/assets/bluetooth.txt');
    final text = await textasset.readAsString();
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).toList();

    final chunks = [];
    //final list4 = [];
    int chunkSize = 19;

    for (int i = 0; i < 40; i += chunkSize) {
      chunks.add(bytes.sublist(
          i, i + chunkSize > bytes.length ? bytes.length : i + chunkSize));
    }

    return chunks;
  }

  static Future<List> startLoad() async {
    const textasset = "assets/112936-bluetooth.txt";
    final text = await rootBundle.loadString(textasset);
    final bytes = text.split(',').map((s) => s.trim()).map((s) => int.parse(s));
    final listbytes = [
      [206, 49]
    ];
    print('ListBytes : $listbytes');
    return listbytes;
  }

  static Future<List<List<String>>> nbrPaquets() async {
    File textasset = File('/storage/emulated/0/RPSApp/assets/bluetooth.txt');
    final text = await textasset.readAsString();
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).length;

    final nbr = [
      [((bytes / 20).ceil().toRadixString(16))]
    ];
    print('nbr paquets : $nbr');
    return nbr;
  }
}
