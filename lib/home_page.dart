import 'package:flutter/material.dart';
import 'dart:math';

import 'login_page.dart';
import 'map/map_page.dart';
import 'add_trash_page.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<MapWidgetState> mapState = GlobalKey<MapWidgetState>();

  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
            ),
          ],
        ),
        body: MapWidget(key: mapState),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            child: Transform.rotate(
                angle: -pi / 4,
                child: const Icon(Icons.explore)
            ),
            onPressed: () async {
              mapState.currentState?.mapController.rotate(0);
            },
            heroTag: "fab1",
            tooltip: "orienta a Nord",
          ),
          FloatingActionButton(
            child: const Icon(Icons.location_on),
            onPressed: () async => mapState.currentState?.moveCenter(),
            heroTag: "fab2",
            tooltip: "rileva posizione",
          ),
          FloatingActionButton(
            child: const Icon(Icons.bug_report),
            onPressed: () async => mapState.currentState?.loadMarkers(),
            heroTag: "fab3",
            tooltip: "mostra oggetti",
          ),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTrashScreen()),
              );
            },
            heroTag: "fab4",
            tooltip: "aggiungi immondizia",
          ),
        ]));
  }
}
