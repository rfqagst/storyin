import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;

class MapScreen extends StatefulWidget {
  final double lat;
  final double lon;
  const MapScreen({super.key, required this.lat, required this.lon});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};
  geo.Placemark? placemark;

  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('storyLocation'),
        position: LatLng(widget.lat, widget.lon),
        infoWindow: const InfoWindow(title: 'Story Location'),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    final info = await geo.placemarkFromCoordinates(widget.lat, widget.lon);

    final place = info[0];
    final street = place.street;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    setState(() {
      placemark = place;
    });

    defineMarker(LatLng(widget.lat, widget.lon), street!, address);

    setState(() {
      mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Story Location'),
      ),
      body: Center(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.lat, widget.lon),
            zoom: 15,
          ),
          markers: _markers,
        ),
      ),
    );
  }

  void defineMarker(LatLng latLng, String street, String address) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: latLng,
      infoWindow: InfoWindow(
        title: street,
        snippet: address,
      ),
    );

    /// todo--03: clear and add a new marker
    setState(() {
      _markers.clear();
      _markers.add(marker);
    });
  }
}
