part of '../find_device_screen.dart';

class ScanResultsList extends StatelessWidget {
  const ScanResultsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (c, snapshot) => Column(
        children: snapshot.data!
            .map(
              (r) => ScanResultTile(
                result: r,
                onTap: () => _goToDeviceScreen(context, r),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Navigate to device screen
  void _goToDeviceScreen(BuildContext context, ScanResult r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          r.device
              .connect(autoConnect: true, timeout: const Duration(seconds: 10));
          return DeviceScreen(device: r.device);
        },
      ),
    );
  }
}
