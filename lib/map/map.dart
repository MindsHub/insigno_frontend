import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:insignio_frontend/map/marker_type.dart';
import 'package:latlong2/latlong.dart';

import 'marker.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  final MapController mapController = MapController();

  Position? position;
  List<MapMarker> markers = List.empty();

  void setPosition(Position? position) {
    setState(() {
      this.position = position;
    });
  }

  void loadMarkers() async {
    final newMarkers = [
      MapMarker(0, 45.75548, 11.00323, MarkerType.electronics),
      MapMarker(0, 45.75559, 11.00323, MarkerType.compost),
      MapMarker(0, 45.75537, 11.00323, MarkerType.glass),
      MapMarker(0, 45.75548, 11.00312, MarkerType.paper),
      MapMarker(0, 45.75548, 11.00334, MarkerType.plastic),
    ];
    setState(() {
      markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: LatLng(45.75548, 11.00323),
        zoom: 15.0,
        maxZoom: 18.45, // OSM supports at most the zoom value 19
        onLongPress: (pos, coords) async {
          MarkerType t = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddObject()),
          );
          setState(() {
            markers.add(MapMarker(0, coords.latitude, coords.longitude, t));
          });
        },
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return const Text("© OpenStreetMap contributors");
          },
        ),
        MarkerLayerOptions(
          markers: (position == null
                  ? <Marker>[]
                  : [
                      Marker(
                        width: 30.0,
                        height: 30.0,
                        point: LatLng(position!.latitude, position!.longitude),
                        builder: (ctx) => SvgPicture.asset(
                            "assets/icons/current_location.svg"),
                      ),
                    ]) +
              markers
                  .map((e) => Marker(
                        point: LatLng(e.latitude, e.longitude),
                        builder: (ctx) => IconButton(
                          icon: Icon(e.type.icon, color: e.type.color),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => Details(
                              title: e.type.name,
                              content: "some garbage description",
                              icon: Icon(e.type.icon, color: e.type.color),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
        ),
      ],
    );
  }
}

class Details extends StatelessWidget {
  final String title;
  final String content;
  final Icon icon;

  const Details({
    required this.title,
    required this.content,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          this.icon,
          SizedBox(width: 10),
          Text(
            this.title,
            //style: Theme.of(context).textTheme.title,
          ),
        ],
      ),
      actions: [
        MaterialButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: Text(
        this.content,
        //style: Theme.of(context).textTheme.body1,
      ),
      backgroundColor: Colors.cyanAccent,
    );
  }
}

class AddObject extends StatefulWidget {
  const AddObject({Key? key}) : super(key: key);

  @override
  State<AddObject> createState() => _AddObjectState();
}

class _AddObjectState extends State<AddObject> {
  late String _description;
  late MarkerType _t = MarkerType.unknown;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi un nuovo oggetto'),
        leading: CloseButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownButtonFormField<MarkerType>(
                  decoration: new InputDecoration(labelText: "Tipo"),
                  value: _t,
                  onChanged: (value) => setState(() {
                    _t = value!;
                  }),
                  items: MarkerType.values
                      .map((e) => DropdownMenuItem<MarkerType>(
                            value: e,
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: ListTile(
                                leading: Icon(e.icon),
                                title: Text(e.name),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                TextFormField(
                  decoration: new InputDecoration(labelText: "Descrizione"),
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(300)],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Inserire una descrizione";
                    }
                    return null;
                  },
                  onSaved: (desc) {
                    _description = desc!;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final item = _t;
                      Navigator.of(context).pop(item);
                    }
                  },
                  child: Icon(Icons.save),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
