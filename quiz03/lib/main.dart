import 'package:flutter/material.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Flashcards',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const QuizHomePage(),
    );
  }
}

class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Map<String, String>> flashcards = [
    {"question": "What is Flutter?", "answer": "A UI toolkit by Google for building apps."},
    {"question": "What language is used in Flutter?", "answer": "Dart programming language."},
    {"question": "What is a StatefulWidget?", "answer": "A widget that maintains state over time."},
    {"question": "What is hot reload?", "answer": "A feature to quickly apply code changes."},
  ];

  int learnedCount = 0;

  // Pull-to-refresh
  Future<void> _refreshList() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      flashcards = [
        {"question": "What is Dart?", "answer": "A programming language for Flutter."},
        {"question": "Who developed Flutter?", "answer": "Google."},
        {"question": "What is a widget?", "answer": "A basic building block of Flutter UI."},
        {"question": "What is MaterialApp?", "answer": "A widget that wraps the whole app UI."},
      ];
      learnedCount = 0;
    });
  }

  void _addNewCard() {
    final newCard = {
      "question": "New Question ${flashcards.length + 1}",
      "answer": "This is the answer for question ${flashcards.length + 1}."
    };
    flashcards.insert(0, newCard);
    _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshList,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 140.0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text("Learned: $learnedCount of ${flashcards.length}"),
                background: Container(color: Colors.deepPurple.shade200),
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedList(
                key: _listKey,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                initialItemCount: flashcards.length,
                itemBuilder: (context, index, animation) {
                  final card = flashcards[index];
                  return SizeTransition(
                    sizeFactor: animation,
                    child: Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          flashcards.removeAt(index);
                          learnedCount++;
                        });
                      },
                      child: FlashCard(
                        question: card["question"]!,
                        answer: card["answer"]!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewCard,
        icon: const Icon(Icons.add),
        label: const Text("Add Card"),
      ),
    );
  }
}

class FlashCard extends StatefulWidget {
  final String question;
  final String answer;

  const FlashCard({super.key, required this.question, required this.answer});

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  bool showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => showAnswer = !showAnswer),
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          color: showAnswer ? Colors.deepPurple.shade50 : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showAnswer ? "Answer:" : "Question:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: showAnswer ? Colors.deepPurple : Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                showAnswer ? widget.answer : widget.question,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
