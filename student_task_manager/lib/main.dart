// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() {
  runApp(const StudentTaskManagerApp());
}

/// =======================
/// Models & Utilities
/// =======================

enum Priority { low, medium, high }

String priorityToString(Priority p) {
  switch (p) {
    case Priority.low:
      return 'Low';
    case Priority.medium:
      return 'Medium';
    case Priority.high:
      return 'High';
  }
}

Priority priorityFromString(String s) {
  switch (s.toLowerCase()) {
    case 'low':
      return Priority.low;
    case 'medium':
      return Priority.medium;
    case 'high':
      return Priority.high;
    default:
      return Priority.low;
  }
}

String formatDateNullable(DateTime? d) {
  if (d == null) return 'No due date';
  return DateFormat.yMMMd().format(d);
}

class Task {
  String id;
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  Priority priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate,
    this.priority = Priority.medium,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.create({
    required String title,
    required String description,
    DateTime? dueDate,
    Priority priority = Priority.medium,
  }) {
    return Task(
      id: _generateId(),
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
    );
  }

  factory Task.fromJson(Map<String, dynamic> j) {
    return Task(
      id: j['id'] as String,
      title: j['title'] as String,
      description: j['description'] as String,
      isCompleted: j['isCompleted'] as bool? ?? false,
      createdAt: j['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(j['createdAt'] as String),
      dueDate:
      j['dueDate'] == null ? null : DateTime.parse(j['dueDate'] as String),
      priority: j['priority'] == null
          ? Priority.medium
          : priorityFromString(j['priority'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'priority': priorityToString(priority),
  };

  static String _generateId() {
    // simple random id
    final rand = Random();
    final part = List<int>.generate(8, (_) => rand.nextInt(256));
    return base64UrlEncode(part);
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    Priority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
    );
  }
}

/// =======================
/// Storage Service
/// =======================

class StorageService {
  static const String _keyTasks = 'stm_tasks';
  static const String _keyThemeDark = 'stm_theme_dark';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyTasks);
    if (jsonString == null) return [];
    try {
      final List decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      // malformed data -> reset
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTasks, jsonString);
  }

  static Future<bool> loadThemeIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeDark) ?? true;
  }

  static Future<void> saveThemeIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeDark, isDark);
  }
}

/// =======================
/// App
/// =======================

class StudentTaskManagerApp extends StatefulWidget {
  const StudentTaskManagerApp({super.key});

  @override
  State<StudentTaskManagerApp> createState() => _StudentTaskManagerAppState();
}

class _StudentTaskManagerAppState extends State<StudentTaskManagerApp> {
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await StorageService.loadThemeIsDark();
    setState(() => _isDark = saved);
  }

  void _toggleTheme(bool value) {
    setState(() => _isDark = value);
    StorageService.saveThemeIsDark(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Task Manager',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.deepPurple),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1F1B24)),
        floatingActionButtonTheme:
        const FloatingActionButtonThemeData(backgroundColor: Colors.deepPurple),
      ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      home: HomePage(onToggleTheme: _toggleTheme, isDark: _isDark),
    );
  }
}

/// =======================
/// Home Page (tabs, search, stats)
/// =======================

class HomePage extends StatefulWidget {
  final Function(bool) onToggleTheme;
  final bool isDark;

  const HomePage({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

enum SortOrder { createdDesc, dueAsc, priorityDesc, titleAsc }

class _HomePageState extends State<HomePage> {
  List<Task> _tasks = [];
  int _currentIndex = 0; // 0 = all, 1 = pending, 2 = completed
  String _search = '';
  SortOrder _sortOrder = SortOrder.createdDesc;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final loaded = await StorageService.loadTasks();
    setState(() {
      _tasks = loaded;
      _isLoading = false;
    });
  }

  Future<void> _saveAll() async {
    await StorageService.saveTasks(_tasks);
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.insert(0, task);
    });
    _saveAll();
  }

  void _updateTask(Task updated) {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      setState(() => _tasks[index] = updated);
      _saveAll();
    }
  }

  void _deleteTask(Task t) {
    final index = _tasks.indexWhere((x) => x.id == t.id);
    if (index == -1) return;
    final removed = _tasks.removeAt(index);
    _saveAll();
    // show undo
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removed.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _tasks.insert(index, removed));
            _saveAll();
          },
        ),
      ),
    );
  }

  void _toggleComplete(Task t) {
    final idx = _tasks.indexWhere((x) => x.id == t.id);
    if (idx == -1) return;
    setState(() {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: !t.isCompleted);
    });
    _saveAll();
  }

  void _setSearch(String s) {
    setState(() => _search = s.trim().toLowerCase());
  }

  void _setSort(SortOrder s) {
    setState(() => _sortOrder = s);
  }

  List<Task> get _filteredAndSorted {
    List<Task> base;
    if (_currentIndex == 1) {
      base = _tasks.where((t) => !t.isCompleted).toList();
    } else if (_currentIndex == 2) {
      base = _tasks.where((t) => t.isCompleted).toList();
    } else {
      base = [..._tasks];
    }

    if (_search.isNotEmpty) {
      base = base.where((t) {
        final title = t.title.toLowerCase();
        final desc = t.description.toLowerCase();
        return title.contains(_search) || desc.contains(_search);
      }).toList();
    }

    // sorting
    switch (_sortOrder) {
      case SortOrder.createdDesc:
        base.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOrder.dueAsc:
        base.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case SortOrder.priorityDesc:
        base.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortOrder.titleAsc:
        base.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return base;
  }

  int get total => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;
  int get dueTodayCount {
    final now = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      final d = t.dueDate!;
      return d.year == now.year && d.month == now.month && d.day == now.day && !t.isCompleted;
    }).length;
  }

  double get progressPercent => total == 0 ? 0.0 : (completedCount / total);

  Future<void> _showAddEditDialog({Task? editTask}) async {
    final result = await showDialog<Task?>(
      context: context,
      builder: (context) => AddEditTaskDialog(existing: editTask),
    );
    if (result != null) {
      if (editTask == null) {
        _addTask(result);
      } else {
        _updateTask(result);
      }
    }
  }

  Future<void> _showTaskDetails(Task t) async {
    await showDialog(
      context: context,
      builder: (context) => TaskDetailsDialog(
        task: t,
        onToggle: () {
          Navigator.pop(context);
          _toggleComplete(t);
        },
        onEdit: () async {
          Navigator.pop(context);
          await _showAddEditDialog(editTask: t);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTask(t);
        },
      ),
    );
  }

  Future<void> _exportToClipboard() async {
    final jsonString = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await Clipboard.setData(ClipboardData(text: jsonString));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tasks copied to clipboard as JSON')));
  }

  Future<void> _importFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No JSON found on clipboard')));
      return;
    }
    try {
      final decoded = jsonDecode(data.text!) as List;
      final imported = decoded.map((e) => Task.fromJson(Map<String, dynamic>.from(e))).toList();
      // merge: simple strategy - append imported tasks
      setState(() => _tasks.insertAll(0, imported));
      await _saveAll();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imported tasks from clipboard')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to import: invalid JSON')));
    }
  }

  Future<void> _confirmClearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all tasks?'),
        content: const Text('This will permanently delete all tasks. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear All')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _tasks.clear());
      await _saveAll();
    }
  }

  Widget _buildStatCard(String label, String value, Color accent) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accent)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _filteredAndSorted;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Task Manager'),
        actions: [
          IconButton(
            tooltip: 'Export (copy JSON)',
            icon: const Icon(Icons.upload_file),
            onPressed: _exportToClipboard,
          ),
          IconButton(
            tooltip: 'Import (paste JSON)',
            icon: const Icon(Icons.download),
            onPressed: _importFromClipboard,
          ),
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'clear') await _confirmClearAll();
              if (v == 'toggle_theme') {
                widget.onToggleTheme(!widget.isDark);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'toggle_theme', child: Text(widget.isDark ? 'Switch to Light' : 'Switch to Dark')),
              const PopupMenuItem(value: 'clear', child: Text('Clear all tasks')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(92),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Search + Sort row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => _setSearch(v),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _setSearch('');
                            },
                          )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<SortOrder>(
                      tooltip: 'Sort',
                      onSelected: _setSort,
                      itemBuilder: (context) => [
                        PopupMenuItem(value: SortOrder.createdDesc, child: const Text('Newest first')),
                        PopupMenuItem(value: SortOrder.dueAsc, child: const Text('Due date ascending')),
                        PopupMenuItem(value: SortOrder.priorityDesc, child: const Text('Priority')),
                        PopupMenuItem(value: SortOrder.titleAsc, child: const Text('Title A→Z')),
                      ],
                      icon: const Icon(Icons.sort),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  children: [
                    _buildStatCard('Total', total.toString(), Colors.blueAccent),
                    _buildStatCard('Completed', completedCount.toString(), Colors.green),
                    _buildStatCard('Due Today', dueTodayCount.toString(), Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayList.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No tasks found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: displayList.length,
        itemBuilder: (context, index) {
          final t = displayList[index];
          final isOverdue = t.dueDate != null && !t.isCompleted && t.dueDate!.isBefore(DateTime.now());
          return Dismissible(
            key: ValueKey(t.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete_forever, color: Colors.white),
            ),
            onDismissed: (_) => _deleteTask(t),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: ListTile(
                onTap: () => _showTaskDetails(t),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isOverdue)
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    const SizedBox(width: 4),
                    Chip(
                      label: Text(priorityToString(t.priority)),
                      backgroundColor: _priorityColor(t.priority).withOpacity(0.12),
                      avatar: CircleAvatar(
                        backgroundColor: _priorityColor(t.priority),
                        radius: 8,
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      t.description.isEmpty ? 'No description' : t.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(
                          t.dueDate == null ? 'No due date' : DateFormat.yMMMd().add_jm().format(t.dueDate!),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                leading: Checkbox(
                  value: t.isCompleted,
                  onChanged: (_) => _toggleComplete(t),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await _showAddEditDialog(editTask: t);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'Add new task',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.list), label: 'All (${total})'),
          BottomNavigationBarItem(icon: const Icon(Icons.pending), label: 'Pending (${pendingCount})'),
          BottomNavigationBarItem(icon: const Icon(Icons.done_all), label: 'Completed (${completedCount})'),
        ],
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }
}

/// =======================
/// Dialogs: Add/Edit, Details
/// =======================

class AddEditTaskDialog extends StatefulWidget {
  final Task? existing;
  const AddEditTaskDialog({super.key, this.existing});

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleC;
  late TextEditingController _descC;
  DateTime? _due;
  Priority _priority = Priority.medium;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleC = TextEditingController(text: e?.title ?? '');
    _descC = TextEditingController(text: e?.description ?? '');
    _due = e?.dueDate;
    _priority = e?.priority ?? Priority.medium;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _due ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    setState(() {
      _due = DateTime(date.year, date.month, date.day, time?.hour ?? 9, time?.minute ?? 0);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleC.text.trim();
    final desc = _descC.text.trim();
    if (widget.existing == null) {
      final newTask = Task.create(title: title, description: desc, dueDate: _due, priority: _priority);
      Navigator.pop(context, newTask);
    } else {
      final updated = widget.existing!.copyWith(
        title: title,
        description: desc,
        dueDate: _due,
        priority: _priority,
      );
      Navigator.pop(context, updated);
    }
  }

  void _clearDue() {
    setState(() => _due = null);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Task' : 'Add Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descC,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(_due == null ? 'No due date' : DateFormat.yMMMd().add_jm().format(_due!)),
                  ),
                  TextButton(onPressed: _pickDueDate, child: const Text('Pick')),
                  if (_due != null) TextButton(onPressed: _clearDue, child: const Text('Clear')),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Priority>(
                value: _priority,
                items: Priority.values
                    .map((p) => DropdownMenuItem(value: p, child: Text(priorityToString(p))))
                    .toList(),
                onChanged: (v) => setState(() => _priority = v ?? Priority.medium),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskDetailsDialog({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null && !task.isCompleted && task.dueDate!.isBefore(DateTime.now());
    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(task.title)),
          if (isOverdue) const Icon(Icons.warning_amber_rounded, color: Colors.red),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(task.description.isEmpty ? 'No description' : task.description),
            const SizedBox(height: 12),
            Text('Created:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(DateFormat.yMMMd().add_jm().format(task.createdAt)),
            const SizedBox(height: 12),
            Text('Due:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(task.dueDate == null ? 'No due date' : DateFormat.yMMMd().add_jm().format(task.dueDate!)),
            const SizedBox(height: 12),
            Text('Priority:', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(priorityToString(task.priority)),
            const SizedBox(height: 18),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                  label: Text(task.isCompleted ? 'Mark Pending' : 'Mark Done'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
