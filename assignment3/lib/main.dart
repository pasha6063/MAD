import 'package:flutter/material.dart';

void main() {
  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Smart Home Dashboard",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xfff3f6fb),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 3,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),

        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.blueAccent.withOpacity(0.2),
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),

      home: DashboardScreen(),
    );
  }
}

/// DEVICE MODEL
class Device {
  String name;
  String type;
  String room;
  bool isOn;

  Device({required this.name, required this.type, required this.room, this.isOn = false});
}

/// MAIN DASHBOARD SCREEN
class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Device> devices = [
    Device(name: "Living Room Light", type: "Light", room: "Living Room", isOn: true),
    Device(name: "Bedroom Fan", type: "Fan", room: "Bedroom", isOn: false),
    Device(name: "Main AC", type: "AC", room: "Hall", isOn: true),
    Device(name: "Front Camera", type: "Camera", room: "Gate", isOn: true),
  ];

  IconData getDeviceIcon(String type) {
    switch (type) {
      case "Light":
        return Icons.lightbulb_outline;
      case "Fan":
        return Icons.toys;
      case "AC":
        return Icons.ac_unit;
      case "Camera":
        return Icons.camera_alt_outlined;
      default:
        return Icons.device_unknown;
    }
  }

  /// ADD NEW DEVICE
  void _addNewDevice() {
    String name = "";
    String room = "";
    String type = "Light";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Device"),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Device Name"),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Room Name"),
                onChanged: (value) => room = value,
              ),
              DropdownButton<String>(
                value: type,
                items: ["Light", "Fan", "AC", "Camera"].map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    type = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  devices.add(Device(name: name, type: type, room: room));
                });
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Home Dashboard"),
        leading: const Icon(Icons.menu),
        actions: const [
          CircleAvatar(
            backgroundImage: AssetImage("assets/profile.png"),
          ),
          SizedBox(width: 12),
        ],
      ),

      /// GRID OF DEVICES
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: devices.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width < 600 ? 2 : 4,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            Device device = devices[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: device)),
                );
              },
              child: AnimatedScale(
                scale: device.isOn ? 1.03 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  color: device.isOn ? Colors.blue.shade50 : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(getDeviceIcon(device.type),
                            size: 50,
                            color: device.isOn ? Colors.blue : Colors.grey),
                        const SizedBox(height: 10),

                        Text(device.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            )),

                        Switch(
                          value: device.isOn,
                          onChanged: (value) {
                            setState(() {
                              device.isOn = value;
                            });
                          },
                        ),

                        Text(
                          device.isOn ? "${device.type} is ON" : "${device.type} is OFF",
                          style: TextStyle(
                            color: device.isOn ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDevice,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// DEVICE DETAIL SCREEN
class DeviceDetailScreen extends StatefulWidget {
  final Device device;

  DeviceDetailScreen({required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  double sliderValue = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        leading: const BackButton(),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.device.type == "Fan"
                  ? Icons.toys
                  : widget.device.type == "Light"
                  ? Icons.lightbulb
                  : widget.device.type == "AC"
                  ? Icons.ac_unit
                  : Icons.camera_alt,
              size: 130,
              color: widget.device.isOn ? Colors.blue : Colors.grey,
            ),

            const SizedBox(height: 20),

            Text(
              widget.device.isOn ? "Status: ON" : "Status: OFF",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            if (widget.device.type == "Fan" || widget.device.type == "Light") ...[
              const SizedBox(height: 30),
              Text(
                widget.device.type == "Fan" ? "Speed" : "Brightness",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Slider(
                min: 0,
                max: 100,
                value: sliderValue,
                onChanged: (newVal) {
                  setState(() {
                    sliderValue = newVal;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
