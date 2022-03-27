import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loading = true;

  endLoading() => setState(() {
    loading = false;
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Insignio",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Insignio"),
        ),
        body: loading
            ? LoadingScreen(
                callback: endLoading,
              )
            : const MyHomePage(title: "Insignio"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String pill = "Caricamento...";

  @override
  void initState() {
    super.initState();
    _loadPill();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            onPressed: () {
              _loadPill();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left:20.0, right:20.0),
              child: Text(
                pill,
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadPill,
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void _loadPill() async {
    var response = await http.get(
      Uri.parse('http://insignio.mindshub.it/pills/random'),
      headers: {'Accept': 'application/json'},
    );

    setState(() {
      pill = json.decode(response.body)["text"];
    });
  }
}
