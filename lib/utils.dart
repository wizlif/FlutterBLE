import 'dart:developer';
import 'dart:io';

class Utils {
  static Future<List> localPath() async {
    File textAsset = File('/storage/emulated/0/RPSApp/assets/bluetooth.txt');
    final text = await textAsset.readAsString();
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).toList();

    final chunks = [];
    int chunkSize = 19;

    for (int i = 0; i < 40; i += chunkSize) {
      chunks.add(bytes.sublist(
          i, i + chunkSize > bytes.length ? bytes.length : i + chunkSize));
    }

    return chunks;
  }

  static Future<List> startLoad() async {
    // const textAsset = "assets/112936-bluetooth.txt";
    // final text = await rootBundle.loadString(textAsset);
    // final bytes = text.split(',').map((s) => s.trim()).map((s) => int.parse(s));
    final listBytes = [
      [206, 49]
    ];
    log('ListBytes : $listBytes');
    return listBytes;
  }

  static Future<List<List<String>>> nbrPaquets() async {
    File textAsset = File('/storage/emulated/0/RPSApp/assets/bluetooth.txt');
    final text = await textAsset.readAsString();
    final bytes =
        text.split(',').map((s) => s.trim()).map((s) => int.parse(s)).length;

    final nbr = [
      [((bytes / 20).ceil().toRadixString(16))]
    ];
    log('nbr paquets : $nbr');
    return nbr;
  }
}
