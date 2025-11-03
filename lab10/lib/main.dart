import 'package:flutter/material.dart';

void main() {
  runApp(const ScrollingListsApp());
}

class ScrollingListsApp extends StatelessWidget {
  const ScrollingListsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrolling Lists Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// MAIN SCREEN WITH TAB NAVIGATION
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Tab> _tabs = const [
    Tab(text: 'Cards'),
    Tab(text: 'ListView'),
    Tab(text: 'GridView'),
    Tab(text: 'Stack'),
    Tab(text: 'Custom Scroll'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scrolling Lists Showcase'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs,
          ),
        ),
        body: const TabBarView(
          children: [
            CardTab(),
            ListViewTab(),
            GridViewTab(),
            StackTab(),
            CustomScrollViewTab(),
          ],
        ),
      ),
    );
  }
}

/// 1. CARD TAB
class CardTab extends StatelessWidget {
  const CardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCard(context, 'Simple Card', 'A basic Material card.'),
        _buildCard(context, 'Colored Card', 'Card with background color.',
            color: Colors.indigo.shade50),
        _buildCard(context, 'Rounded Card',
            'Card with rounded corners and shadow.',
            elevation: 10),
      ],
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle,
      {Color? color, double elevation = 4}) {
    return Card(
      color: color,
      elevation: elevation,
      child: ListTile(
        leading: const Icon(Icons.layers, color: Colors.indigo),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

/// 2. LISTVIEW TAB
class ListViewTab extends StatelessWidget {
  const ListViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.star, color: Colors.amber),
          title: Text('List Item ${index + 1}'),
          subtitle: const Text('Example of a scrollable list.'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}

/// 3. GRIDVIEW TAB
class GridViewTab extends StatelessWidget {
  const GridViewTab({super.key});

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.work, 'label': 'Work'},
    {'icon': Icons.school, 'label': 'School'},
    {'icon': Icons.favorite, 'label': 'Favorite'},
    {'icon': Icons.star, 'label': 'Star'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item['icon'], size: 40, color: Colors.indigo),
              const SizedBox(height: 8),
              Text(item['label'], style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        );
      },
    );
  }
}

/// 4. STACK TAB
class StackTab extends StatelessWidget {
  const StackTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Layer
        Container(color: Colors.indigo.shade100),

        // Center Content
        Center(
          child: Container(
            width: 220,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: const Center(
              child: Text('Centered Box',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ),
        ),

        // Decorative Icons
        const Positioned(
          top: 20,
          left: 20,
          child: Icon(Icons.star, size: 40, color: Colors.amber),
        ),
        const Positioned(
          bottom: 20,
          right: 20,
          child: Icon(Icons.favorite, size: 40, color: Colors.red),
        ),
      ],
    );
  }
}

/// 5. CUSTOM SCROLL VIEW TAB
class CustomScrollViewTab extends StatelessWidget {
  const CustomScrollViewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          floating: true,
          pinned: true,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text('Custom Scroll View'),
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.shade200,
                  child: Text('${index + 1}'),
                ),
                title: Text('Sliver Item ${index + 1}'),
                subtitle: const Text('Scroll smoothly with app bar animation.'),
              );
            },
            childCount: 8,
          ),
        ),
      ],
    );
  }
}
