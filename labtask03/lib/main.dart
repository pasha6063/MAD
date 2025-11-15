import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DeviceInfoApp());

class DeviceInfoApp extends StatelessWidget {
  const DeviceInfoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Platform Channel",
      debugShowCheckedModeBanner: false,
      home: const DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static const platform =
  MethodChannel("platformchannel.companyname.com/deviceinfo");

  String _deviceInfo = "Tap button to get info";

  Future<void> getDeviceInfo() async {
    try {
      final result = await platform.invokeMethod<String>("getDeviceInfo");
      setState(() => _deviceInfo = result ?? "No Data");
    } on PlatformException catch (e) {
      setState(() => _deviceInfo = "Error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Platform Channel")),
      body: SafeArea(
        child: ListTile(
          title: const Text(
            "Device info:",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(_deviceInfo),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.info),
        onPressed: getDeviceInfo,
      ),
    );
  }
}
