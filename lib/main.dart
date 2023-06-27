import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
          home: MyHomePage(),
        ));
  }
}

class MyAppState extends ChangeNotifier {
  var currentWord = WordPair.random();

  var favoriteWords = <WordPair>[];

  void generateWord() {
    currentWord = WordPair.random();
    notifyListeners();
  }

  void addFavoriteWord() {
    if (favoriteWords.contains(currentWord)) {
      favoriteWords.remove(currentWord);
    } else {
      favoriteWords.add(currentWord);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          body: Row(
        children: [
          SafeArea(
              child: NavigationRail(
            extended: constraints.maxWidth >= 600,
            destinations: [
              NavigationRailDestination(
                  icon: Icon(Icons.home), label: Text("Home")),
              NavigationRailDestination(
                  icon: Icon(Icons.favorite), label: Text("Favorites")),
            ],
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() {
                selectedIndex = value;
              });
            },
          )),
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page),
          )
        ],
      ));
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var word = appState.currentWord;
    var favoriteWords = appState.favoriteWords;

    IconData icon;

    if (favoriteWords.contains(word)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        WordCard(word: word),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                icon: Icon(icon),
                onPressed: () {
                  appState.addFavoriteWord();
                  Future.delayed(Duration(milliseconds: 600), () {
                    appState.generateWord();
                  });
                },
                label: Text("Like")),
            SizedBox(width: 20),
            ElevatedButton(
                onPressed: () => appState.generateWord(),
                child: Text("Generate"))
          ],
        ),
      ]),
    );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
  });

  final WordPair word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary, shadows: [
      Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(5, 5),
          blurRadius: 5),
    ]);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          word.asLowerCase,
          style: style,
          semanticsLabel: "${word.first} ${word.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favoriteWords = appState.favoriteWords;

    if (favoriteWords.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Text('You have ' '${favoriteWords.length} favorites:')),
        for (var pair in favoriteWords)
          ListTile(leading: Icon(Icons.favorite), title: Text(pair.asLowerCase))
      ],
    );
  }
}
