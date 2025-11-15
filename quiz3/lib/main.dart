import 'package:flutter/material.dart';

void main() {
  runApp(const FlashcardApp());
}

class FlashcardApp extends StatelessWidget {
  const FlashcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const FlashcardHome(),
    );
  }
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard(this.question, this.answer);
}

class FlashcardHome extends StatefulWidget {
  const FlashcardHome({super.key});

  @override
  State<FlashcardHome> createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  List<Flashcard> flashcards = [
    Flashcard("What is Flutter?", "A UI toolkit by Google."),
    Flashcard("What is Dart?", "Programming language for Flutter."),
    Flashcard("What is a widget?", "A building block of Flutter UI."),
    Flashcard("What is StatefulWidget?", "Widget with mutable state."),
    Flashcard("What is setState()?", "Used to update the UI."),
  ];

  int learnedCount = 0;

  // Simulate refresh (new quiz set)
  Future<void> _refreshFlashcards() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      learnedCount = 0;
      flashcards = [
        Flashcard("What is hot reload?", "Reloads app without losing state."),
        Flashcard("What is MaterialApp?", "Root widget for Material design."),
        Flashcard("What is Scaffold?", "Provides basic app layout structure."),
        Flashcard("What is Column?", "Arranges widgets vertically."),
        Flashcard("What is Row?", "Arranges widgets horizontally."),
      ];
    });
  }

  void _addNewFlashcard() {
    final newCard = Flashcard("New Question?", "New Answer!");
    flashcards.insert(0, newCard);
    _listKey.currentState!.insertItem(0, duration: const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFlashcard,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFlashcards,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Learned $learnedCount of ${flashcards.length}'),
                background: Container(color: Colors.deepPurple),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedList(
                key: _listKey,
                initialItemCount: flashcards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index, animation) {
                  final card = flashcards[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      key: UniqueKey(),
                      onDismissed: (_) {
                        setState(() {
                          flashcards.removeAt(index);
                          learnedCount++;
                        });
                      },
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      child: FlashcardTile(card: card),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardTile extends StatefulWidget {
  final Flashcard card;

  const FlashcardTile({super.key, required this.card});

  @override
  State<FlashcardTile> createState() => _FlashcardTileState();
}

class _FlashcardTileState extends State<FlashcardTile> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        title: Text(
          _showAnswer ? widget.card.answer : widget.card.question,
          style: TextStyle(
            fontSize: 18,
            fontWeight: _showAnswer ? FontWeight.bold : FontWeight.normal,
            color: _showAnswer ? Colors.green.shade700 : Colors.black,
          ),
        ),
        trailing: Icon(
          _showAnswer ? Icons.visibility_off : Icons.visibility,
          color: Colors.deepPurple,
        ),
        onTap: () {
          setState(() {
            _showAnswer = !_showAnswer;
          });
        },
      ),
    );
  }
}
