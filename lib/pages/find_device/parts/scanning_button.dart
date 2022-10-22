part of '../find_device_screen.dart';

class ScanningButton extends StatelessWidget {
  const ScanningButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: FlutterBlue.instance.isScanning,
      initialData: false,
      builder: (c, snapshot) {
        final isScanning = snapshot.data ?? false;
        // log(isScanning.toString());
        if (isScanning) {
          return FloatingActionButton(
            onPressed: () => FlutterBlue.instance.stopScan(),
            backgroundColor: Colors.red,
            child: const Icon(Icons.stop),
          );
        } else {
          return FloatingActionButton(
            child: const Icon(Icons.search),
            onPressed: () => FlutterBlue.instance.startScan(
              timeout: const Duration(seconds: 4),
            ),
          );
        }
      },
    );
  }
}
