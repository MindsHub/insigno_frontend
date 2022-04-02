import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoadingScreen extends StatefulWidget {
  final Function() callback;

  const LoadingScreen({Key? key, required this.callback}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  late Future<String> serverPill;

  @override
  void initState() {
    super.initState();
    serverPill = _loadPill();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left:20.0, right:20.0),
          child: FutureBuilder<String>(
            future: serverPill,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data!,
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          )
        ),
        const SizedBox(height: 60),
        FloatingActionButton(
          child: const Icon(Icons.navigate_next),
          onPressed: () => widget.callback(),
        ),
      ],
    );
  }

  Future<String> _loadPill() async {
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
