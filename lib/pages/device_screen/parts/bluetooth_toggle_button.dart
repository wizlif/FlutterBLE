part of '../device_screen.dart';

class BluetoothToggleButton extends StatelessWidget {
  final BluetoothDevice device;
  const BluetoothToggleButton({Key? key,required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothDeviceState>(
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
          ),
        );
      },
    );
  }
}
