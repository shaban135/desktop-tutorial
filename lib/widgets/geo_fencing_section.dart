import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:mepco_esafety_app/widgets/shimmer_widget.dart';

class GeoFencingSection extends StatelessWidget {
  final RxBool isFetchingLocation;
  final Rxn<LatLng> currentLocation;
  final Function(GoogleMapController)? onMapCreated;

  const GeoFencingSection({
    super.key,
    required this.isFetchingLocation,
    required this.currentLocation,
    this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Geo-Fencing & Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text('  |  '),
            Text(
              'جیو فینسنگ اور مقام',
              style: TextStyle(color: Colors.grey, fontFamily: 'NotoNastaliqUrdu'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: Obx(() {
            if (isFetchingLocation.value) {
              return const ShimmerWidget.rectangular(height: 150);
            } else if (currentLocation.value != null) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: currentLocation.value!,
                  zoom: 15.0,
                ),
                onMapCreated: onMapCreated,
                markers: {
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: currentLocation.value!,
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              );
            } else {
              return const Center(child: Text('Could not fetch location.'));
            }
          }),
        ),
      ],
    );
  }
}
