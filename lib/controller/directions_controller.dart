import 'package:get/get.dart';
import 'package:google_directions_api/google_directions_api.dart';

class DirectionsController extends GetxController {
  final directionsService = DirectionsService();
  var directionsRoute = Rxn<DirectionsRoute>();

  getRoute(double srcLat, double srcLng, double destLat, double destLng, {TravelMode mode = TravelMode.driving}) async {
    final request = DirectionsRequest(
      origin: "$srcLat,$srcLng",
      destination: "$destLat,$destLng",
      travelMode: mode,
    );

    await directionsService.route(request,(DirectionsResult response, DirectionsStatus? status) {

          if (status == DirectionsStatus.ok) {
            if(response.routes == null || response.routes!.isEmpty) {
              return;
            }

            directionsRoute.update((val) {directionsRoute.value = response.routes![0];});
          } else {
            // do something with error response
          }
        });
  }
}