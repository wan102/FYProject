import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controller/maps_controller.dart';

class MainMaps extends StatefulWidget {
  const MainMaps({Key? key}) : super(key: key);

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final _initialCameraPosition = const CameraPosition(target: LatLng(22.3305586, 114.1277085), zoom: 11);
  GoogleMapController? _googleMapController;
  final MapsController _mapController = Get.find<MapsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          markers: _mapController.gpsMarker.value == null
              ? _mapController.markers
              : {
                  ..._mapController.markers,
                  _mapController.gpsMarker.value!,
                },
          onTap: (pos) {
            //_mapController.removeAllMarker();
          },
          onMapCreated: onMapCreated);
    });
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  onMapCreated(controller) {
    _mapController.setGoogleMapController(controller);
    //_mapController.markers.add(Marker(markerId: MarkerId("1"), position: LatLng(22.3305586,114.1277085)));
    //_mapController.addMarker(Marker(markerId: MarkerId("1"), position: LatLng(22.3305586,114.1277085)));
  }
}
