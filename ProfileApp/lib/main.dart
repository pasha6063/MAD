import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ProfileApp',
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController(text: "Gaganpur Pasha");
  String _description =
      "A friendly student learning Flutter and preparing a neat profile screen.";

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveName() {
    if (_formKey.currentState!.validate()) {
      // valid input -> update description or show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name saved!')),
      );
      setState(() {
        // optionally update something with the new name
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Screen')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // Use a column for the main layout
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture (using CircleAvatar with Icon so no asset needed)
              const CircleAvatar(
                radius: 48,
                child: Icon(Icons.person, size: 48),
              ),
              const SizedBox(height: 12),

              // RichText: bold name, smaller email
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: "${_nameCtrl.text}\n",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const TextSpan(
                      text: "student@example.com",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Row with two buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // example action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Elevated button pressed')),
                      );
                    },
                    child: const Text('Follow'),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Text button pressed')),
                      );
                    },
                    child: const Text('Message'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Container with background color and padding for short description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_description),
              ),
              const SizedBox(height: 16),

              // Form with TextField to edit username and show validation
              Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onChanged: (v) {
                          // Update UI immediately so RichText shows name live:
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveName,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),

              // Spacer pushes orientation text to bottom
              const Spacer(),

              // Orientation display using MediaQuery
              Text(
                'Orientation: ${orientation == Orientation.portrait ? "Portrait" : "Landscape"}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}