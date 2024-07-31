import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;

class PickMapScreen extends StatefulWidget {
  final Function() onPickedLocation;
  const PickMapScreen({super.key, required this.onPickedLocation});

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};

  final dicodingOffice = const LatLng(-6.8957473, 107.6337669);

  geo.Placemark? placemark;
  String? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Pick Location"),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      zoom: 18,
                      target: LatLng(-6.938109860738086, 110.91474202390091),
                    ),
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    myLocationEnabled: true,
                    markers: markers,
                    onMapCreated: (GoogleMapController controller) async {
                      mapController = controller;

                      final myLocation = await getMyLocation();
                      if (myLocation != null) {
                        final info = await geo.placemarkFromCoordinates(
                            myLocation.latitude, myLocation.longitude);
                        final place = info[0];
                        final street = place.street!;
                        final address =
                            '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
                        setState(() {
                          placemark = place;
                        });
                        defineMarker(myLocation, street, address);
                      }
                    },
                    onLongPress: (LatLng latLng) {
                      onLongPressGoogleMap(latLng);
                    },
                  ),
                ],
              ),
            ),
            if (selectedAddress != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected Address: $selectedAddress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed:
                      selectedAddress != null ? widget.onPickedLocation : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFF10439F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Confirm Address",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<LatLng?> getMyLocation() async {
    final Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("Location services is not available");
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("Location permission is denied");
        return null;
      }
    }

    locationData = await location.getLocation();
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  void defineMarker(LatLng latLng, String street, String address) {
    final marker = Marker(
        markerId: const MarkerId("source"),
        position: latLng,
        infoWindow: InfoWindow(
          title: street,
          snippet: address,
        ));

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  void onLongPressGoogleMap(LatLng latLng) async {
    final info =
        await geo.placemarkFromCoordinates(latLng.latitude, latLng.longitude);
    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

    defineMarker(latLng, street, address);

    setState(() {
      placemark = place;
      selectedAddress = address;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }
}
