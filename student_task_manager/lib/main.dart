import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const StudentTaskManager());
}

class StudentTaskManager extends StatelessWidget {
  const StudentTaskManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF64B5F6),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        cardColor: const Color(0xFF1D1E33),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

// Main Navigation between 3 screens
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF111328),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white60,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// ---------------- HOME SCREEN ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return isWide
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SummaryCard(title: 'Pending Tasks', count: 6, color: Colors.orangeAccent),
                  SummaryCard(title: 'Completed Tasks', count: 12, color: Colors.greenAccent),
                  SummaryCard(title: 'Overdue', count: 2, color: Colors.redAccent),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SummaryCard(title: 'Pending Tasks', count: 6, color: Colors.orangeAccent),
                  SizedBox(height: 20),
                  SummaryCard(title: 'Completed Tasks', count: 12, color: Colors.greenAccent),
                  SizedBox(height: 20),
                  SummaryCard(title: 'Overdue', count: 2, color: Colors.redAccent),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 220,
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, color: Colors.white70)),
          const SizedBox(height: 10),
          Text('$count', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// ---------------- TASKS SCREEN ----------------
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'Flutter Assignment', 'due': DateTime.now().add(const Duration(days: 1)), 'done': false},
    {'title': 'DBMS Project', 'due': DateTime.now().add(const Duration(days: 2)), 'done': true},
  ];

  void _addTaskDialog() {
    String newTitle = '';
    DateTime? newDue;

    showModalBottomSheet(
      backgroundColor: const Color(0xFF1D1E33),
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Add Task',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                    onChanged: (v) => newTitle = v,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          newDue == null
                              ? 'No due date'
                              : 'Due: ${DateFormat.yMMMd().add_jm().format(newDue!)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today, color: Colors.white70),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModal(() => newDue = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    ),
                    onPressed: () {
                      if (newTitle.isNotEmpty) {
                        setState(() {
                          _tasks.add({
                            'title': newTitle,
                            'due': newDue ?? DateTime.now(),
                            'done': false,
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Add Task'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _tasks.isEmpty
            ? const Center(
            child: Text('No tasks yet!', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, i) {
            final t = _tasks[i];
            return Card(
              color: const Color(0xFF1D1E33),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(t['title'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'Due: ${DateFormat.yMMMd().format(t['due'])}',
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: Checkbox(
                  value: t['done'],
                  activeColor: Colors.greenAccent,
                  onChanged: (v) => setState(() => t['done'] = v ?? false),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ---------------- SETTINGS SCREEN ----------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.dark_mode, size: 80, color: Colors.blueAccent),
              SizedBox(height: 20),
              Text('Dark Theme Enabled',
                  style: TextStyle(fontSize: 20, color: Colors.white70)),
              SizedBox(height: 10),
              Text('Web version running in Chrome',
                  style: TextStyle(color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }
}
