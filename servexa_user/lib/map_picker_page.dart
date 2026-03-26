import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {

  GoogleMapController? mapController;

  LatLng currentPosition = const LatLng(10.8505, 76.2711);

  String address = "Detecting location...";

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  /// GET USER CURRENT LOCATION
  Future<void> getCurrentLocation() async {

    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentPosition = LatLng(position.latitude, position.longitude);

    getAddress(currentPosition);

    setState(() {});
  }

  /// GET ADDRESS FROM LAT LNG
  Future<void> getAddress(LatLng position) async {

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks.first;

    setState(() {
      address =
      "${place.street}, ${place.locality}, ${place.administrativeArea}";
    });
  }

  /// MAP MOVING
  void onCameraMove(CameraPosition position) {
    currentPosition = position.target;
  }

  /// MAP STOPPED
  void onCameraIdle() {
    getAddress(currentPosition);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Select Location"),
      ),

      body: Stack(
        children: [

          /// GOOGLE MAP
          GoogleMap(

            initialCameraPosition: CameraPosition(
              target: currentPosition,
              zoom: 16,
            ),

            myLocationEnabled: true,

            onMapCreated: (controller) {
              mapController = controller;
            },

            onCameraMove: onCameraMove,

            onCameraIdle: onCameraIdle,
          ),

          /// CENTER PIN
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: Colors.red,
            ),
          ),

          /// ADDRESS CARD
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,

            child: Container(

              padding: const EdgeInsets.all(16),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Selected Address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(address),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: () {

                        Navigator.pop(context, {
                          "lat": currentPosition.latitude,
                          "lng": currentPosition.longitude,
                          "address": address
                        });

                      },

                      child: const Text("Confirm Location"),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}