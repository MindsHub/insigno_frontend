import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoadingScreen extends StatefulWidget {
  late List<String> Pills;
  late int i;
  final Function() callback;

  LoadingScreen({Key? key, required this.callback}) : super(key: key) {
    Pills = ["Pillola 1", "Pillola 2", "Pillola 3"];
    i = new Random().nextInt(Pills.length);
  }

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<String> serverPill;

  @override
  void initState() {
    super.initState();
    serverPill = getPill();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
            child: FutureBuilder<String>(
          future: serverPill,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!);
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        )),
        SizedBox(
          height: 100,
        ),
        FloatingActionButton(
          child: Icon(Icons.navigate_next),
          onPressed: () => widget.callback(),
        ),
      ],
    );
  }

  Future<String> getPill() async {
    final response =
        await http.get(Uri.parse('http://insignio.mindshub.it/pills/random'));

    if (response.statusCode == 200) {
      Map<String, dynamic> m = jsonDecode(response.body);
      return m['text'];
    } else {
      throw Exception('Failed to load');
    }
  }
}
