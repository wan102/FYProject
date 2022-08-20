import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_app/controller/maps_controller.dart';
import 'package:maps_app/controller/search_result_controller.dart';

class SearchController extends GetxController {
  var searchResultController = Get.find<SearchResultController>();
  var mapController = Get.find<MapsController>();
  var selectedMarkerId = "".obs;

  searchNearBy(double lat, double lng, String type, {radius = 50000}) async {
    mapController.removeAllMarker();
    await for (var result in searchResultController.searchNearBy(lat, lng, type, radius: radius)) {
      if (result == null) {
        return;
      }

      var markers = result.map<Marker>((el) {
        return Marker(markerId: MarkerId(el.id), position: LatLng(el.lat, el.lng), onTap: () {
          selectedMarkerId.value = el.id;
        });
      }).toSet();
      mapController.addAllMarker(markers);
    }
  }

  searchText(String query, double lat, double lng) async {
    mapController.removeAllMarker();
    await for (var result in searchResultController.searchText(query, lat, lng)) {
      if (result == null) {
        return;
      }

      var markers = result.map<Marker>((el) {
        return Marker(markerId: MarkerId(el.id), position: LatLng(el.lat, el.lng), onTap: () {
          selectedMarkerId.value = el.id;
        });
      }).toSet();
      mapController.addAllMarker(markers);
    }
  }

}