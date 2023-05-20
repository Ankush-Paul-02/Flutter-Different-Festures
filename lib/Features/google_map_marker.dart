import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class GoogleMapMarker extends StatefulWidget {
  const GoogleMapMarker({super.key});

  @override
  State<GoogleMapMarker> createState() => _GoogleMapMarkerState();
}

class _GoogleMapMarkerState extends State<GoogleMapMarker> {
  final Completer<GoogleMapController> _completer = Completer();
  late GoogleMapController googleMapController;

  CustomMapNotifier customMapNotifier({required bool renderUI}) =>
      Provider.of<CustomMapNotifier>(context, listen: renderUI);

  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Marker> markers = customMapNotifier(renderUI: true).markers;
    bool isSingleMarkerMode =
        customMapNotifier(renderUI: true).isSingleMarkerMode;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                ActionChip(
                  backgroundColor: Colors.red,
                  onPressed: () =>
                      customMapNotifier(renderUI: false).clearMarkers(),
                  label: const Text(
                    'Clear markers',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ActionChip(
                  backgroundColor:
                      isSingleMarkerMode ? Colors.blue : Colors.grey,
                  onPressed: () => customMapNotifier(renderUI: false)
                      .toggleMarkerMode(value: true),
                  label: const Text(
                    'Set single marker',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ActionChip(
                  backgroundColor:
                      !isSingleMarkerMode ? Colors.blue : Colors.grey,
                  onPressed: () => customMapNotifier(renderUI: false)
                      .toggleMarkerMode(value: false),
                  label: const Text(
                    'Set multiple marker',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Google maps marker',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: GoogleMap(
        markers: Set.from(markers),
        onTap: (latLng) {
          customMapNotifier(renderUI: false).addMarker(latLng: latLng);
        },
        onMapCreated: (controller) {
          _completer.complete(controller);
          googleMapController = controller;
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(22.5726, 88.3639),
          zoom: 12,
        ),
      ),
    );
  }
}

class CustomMapNotifier extends ChangeNotifier {
  List<Marker> markers = [];
  bool isSingleMarkerMode = false;

  void toggleMarkerMode({required bool value}) {
    isSingleMarkerMode = !isSingleMarkerMode;
    notifyListeners();
  }

  Future addMarker({required LatLng latLng}) async {
    if (isSingleMarkerMode) {
      markers.clear();
      Marker marker = Marker(
        position: LatLng(latLng.latitude, latLng.longitude),
        markerId: MarkerId(
          latLng.toString(),
        ),
      );
      markers.add(marker);
      notifyListeners();
    } else {
      Marker marker = Marker(
          position: LatLng(latLng.latitude, latLng.longitude),
          markerId: MarkerId(latLng.toString()));
      markers.add(marker);
      notifyListeners();
    }
    MarkerId markerId = MarkerId(latLng.toString());
    Marker marker = Marker(markerId: markerId, position: latLng);
    markers.add(marker);
    notifyListeners();
  }

  void clearMarkers() {
    markers.clear();
    notifyListeners();
  }
}
