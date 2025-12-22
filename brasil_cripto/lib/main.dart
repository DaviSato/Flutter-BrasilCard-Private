import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrasilCripto',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.amber,
          secondary: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'BrasilCripto'),
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Brasil Cripto')),
        body: Center(
          child: Column(
            mainAxisAlignment: .start,
            children: [
              SearchBar(hintText: 'Search cryptocurrencies', leading: const Icon(Icons.search)),

              const Text('No data available yet.'),
            ],
          ),
        ),
      ),
    );
  }
}
