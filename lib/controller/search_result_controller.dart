import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/controller/maps_controller.dart';

import '../model/place.dart';

class SearchResultController extends GetxController {
  var googlePlace = Get.find<GooglePlace>();
  var mapController = Get.find<MapsController>();
  var result = RxList<Place>();

  Stream<List<Place>?> searchNearBy(double lat, double lng, String type, {radius = 500000}) async* {
    String? pageToken;
    result.clear();

    for (var i = 0; i < 1; i++) {
      if (i != 0) {
        await Future.delayed(Duration(seconds: 2));
      }

      var res = await googlePlace.search.getNearBySearch(Location(lat: lat, lng: lng), 500000, type: type, pagetoken: pageToken);
      if (res == null || res.results == null) {
        break;
      }

      var places = _resultsToPlaces(res.results!);
      result.addAll(places);
      yield places;
      pageToken = res.nextPageToken;
      if (pageToken == null) {
        break;
      }
    }
  }

  Stream<List<Place>?> searchText(String query, double lat, double lng) async* {
    String? pageToken;
    result.clear();

    for (var i = 0; i < 1; i++) {
      if (i != 0) {
        await Future.delayed(Duration(seconds: 2));
      }

      var res = await googlePlace.search.getTextSearch(query, location: Location(lat: lat, lng: lng));
      if (res == null || res.results == null) {
        break;
      }

      var places = _resultsToPlaces(res.results!);
      result.addAll(places);
      yield places;

      pageToken = res.nextPageToken;
      if (pageToken == null) {
        break;
      }
    }
  }

  List<Place> _resultsToPlaces(List<SearchResult> result) {
    return result.map<Place>((el) {
      return Place(
          id: el.placeId ?? "",
          name: el.name ?? "",
          openStatus: el.openingHours?.openNow,
          rating: el.rating ?? 5,
          address: el.vicinity ?? "",
          lat: el.geometry!.location!.lat!,
          lng: el.geometry!.location!.lng!,
          photos: el.photos?.map<String>((ell) => ell.photoReference!).toList());
    }).toList();
  }
}
