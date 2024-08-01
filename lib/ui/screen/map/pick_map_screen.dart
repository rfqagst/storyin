import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:storyin/routes/page_manager.dart';

class PickMapScreen extends StatefulWidget {
  final Function(PickedLocation) onPickedLocation;
  const PickMapScreen({super.key, required this.onPickedLocation});

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};

  geo.Placemark? placemark;
  String? selectedAddress;
  String? selectedStreet;
  LatLng? userLocation;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Pick Location"),
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: Color.fromARGB(19, 99, 98, 98),
                offset: Offset(0, 4),
                blurRadius: 10)
          ]),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  if (userLocation != null)
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        zoom: 18,
                        target: userLocation!,
                      ),
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      myLocationEnabled: true,
                      markers: markers,
                      onMapCreated: (GoogleMapController controller) async {
                        mapController = controller;
                      },
                      onLongPress: (LatLng latLng) {
                        onLongPressGoogleMap(latLng);
                      },
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            if (selectedAddress != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Selected Address: $selectedStreet $selectedAddress',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    if (selectedAddress != null && userLocation != null) {
                      final locationData = PickedLocation(
                          userLocation!.latitude,
                          userLocation!.longitude,
                          selectedAddress!);
                      widget.onPickedLocation(locationData);
                      context.read<PageManager>().returnData(locationData);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please select a location first."),
                      ));
                    }
                  },
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

  Future<void> _getUserLocation() async {
    try {
      final location = Location();
      final serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        await location.requestService();
      }

      final permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        await location.requestPermission();
      }

      final locationData = await location.getLocation();
      userLocation = LatLng(locationData.latitude!, locationData.longitude!);

      final info = await geo.placemarkFromCoordinates(
          userLocation!.latitude, userLocation!.longitude);
      final place = info[0];
      selectedAddress =
          '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
      selectedStreet = place.street;

      setState(() {
        placemark = place;
      });
      defineMarker(userLocation!, selectedStreet!, selectedAddress!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengambil lokasi.'),
        ),
      );
    }
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
      selectedStreet = street;
      userLocation = latLng;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }
}
