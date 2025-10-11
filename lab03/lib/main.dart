import 'package:flutter/material.dart';

void main() {
  // Console print examples
  print("Hello world");

  var name = 'Pasha';
  print('My name is $name');

  String hobby = 'Watch Series';
  print('My name is $name and my hobby is $hobby');

  const int age = 21;
  print('My name is $name, my hobby is $hobby, and my age is $age');

  String multilineAddress = '''House no 15, Street no 19A, Awan Town, RWP''';
  print(multilineAddress);

  bool alive = true;
  print('Yes, alive: $alive');

  // List example
  List<String> fruits = ['Apple', 'Grapes', 'Banana'];
  print('First fruit: ${fruits[0]}');

  for (var fruit in fruits) {
    print('Fruit name: $fruit');
  }

  // Map example
  Map<String, String> names = {'id1': 'Haroon', 'id2': 'Pasha', 'id3': 'Abrar'};
  print('Get value with id3: ${names['id3']}');

  // Emoji using Runes
  Runes myEmoji = Runes('\u{1F607}');
  print(myEmoji);
  print(String.fromCharCodes(myEmoji));

  // Function inside main
  int add(int a, int b) => a + b;
  print("Sum of 5 + 3 = ${add(5, 3)}");

  // Class Example
  Student s1 = Student("Ali", 20);
  Student s2 = Student("Sara", 22);

  s1.displayInfo();
  s2.displayInfo();

  // ✅ Run Flutter app after prints
  runApp(const MyApp());
}

// ===== CLASS DEFINITION =====
class Student {
  String name;
  int age;

  Student(this.name, this.age);

  void displayInfo() {
    print("Student Name: $name, Age: $age");
  }
}

// ===== FLUTTER UI CODE =====
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
