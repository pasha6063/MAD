import 'package:flutter/material.dart';

void main() {
  runApp(const TravelGuideApp());
}

class TravelGuideApp extends StatelessWidget {
  const TravelGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ListScreen(),
    AboutScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Guide')),
      body: SafeArea(child: _screens[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.teal,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Destinations'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
        ],
      ),
    );
  }
}

//
// -------------------- HOME SCREEN --------------------
//
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController destinationController = TextEditingController();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Welcome to Travel Guide! Discover amazing destinations and plan your next adventure easily.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                text: 'Explore the ',
                style: TextStyle(fontSize: 22, color: Colors.black87),
                children: [
                  TextSpan(
                      text: 'World ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.teal)),
                  TextSpan(text: 'with Us!'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: destinationController,
              decoration: InputDecoration(
                labelText: 'Enter Destination',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Searching destinations...'),
                      ),
                    );
                  },
                  child: const Text('Search'),
                ),
                TextButton(
                  onPressed: () {
                    print('Explore button clicked');
                  },
                  child: const Text('Explore'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//
// -------------------- LIST SCREEN --------------------
//
class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  final List<Map<String, String>> destinations = const [
    {'name': 'Paris', 'desc': 'The city of light and love.'},
    {'name': 'Tokyo', 'desc': 'A fusion of tradition and technology.'},
    {'name': 'New York', 'desc': 'The city that never sleeps.'},
    {'name': 'Dubai', 'desc': 'Luxury and modern architecture.'},
    {'name': 'London', 'desc': 'Historic landmarks and culture.'},
    {'name': 'Rome', 'desc': 'Home of ancient wonders.'},
    {'name': 'Bangkok', 'desc': 'Vibrant street life and temples.'},
    {'name': 'Sydney', 'desc': 'Beaches and the iconic Opera House.'},
    {'name': 'Istanbul', 'desc': 'Where East meets West.'},
    {'name': 'Maldives', 'desc': 'Tropical paradise islands.'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final place = destinations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text(place['name']![0]),
            ),
            title: Text(place['name']!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(place['desc']!),
          ),
        );
      },
    );
  }
}

//
// -------------------- ABOUT SCREEN --------------------
//
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  final List<Map<String, String>> attractions = const [
    {
      'image': 'https://images.unsplash.com/photo-1505765050516-f72dcac9c60b',
      'name': 'Eiffel Tower'
    },
    {
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
      'name': 'Great Wall of China'
    },
    {
      'image': 'https://images.unsplash.com/photo-1491553895911-0055eca6402d',
      'name': 'Colosseum'
    },
    {
      'image': 'https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1',
      'name': 'Taj Mahal'
    },
    {
      'image': 'https://images.unsplash.com/photo-1500534623283-312aade485b7',
      'name': 'Pyramids of Giza'
    },
    {
      'image': 'https://images.unsplash.com/photo-1528909514045-2fa4ac7a08ba',
      'name': 'Statue of Liberty'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: attractions.length,
      itemBuilder: (context, index) {
        final place = attractions[index];
        return Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    place['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  place['name']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
