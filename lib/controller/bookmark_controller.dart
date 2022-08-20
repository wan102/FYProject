import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/place.dart';


class BookmarkController extends GetxController with StateMixin<List<Place>> {
  var googlePlace = Get.find<GooglePlace>();
  final _supabase = Get.find<SupabaseClient>();

  BookmarkController(){
    bookmarks();
  }

  bookmarks() async {
    if(state != null && state!.isNotEmpty) {
      return;
    }

    final res = await _supabase
        .from('place_bookmark')
        .select("""
          *,
          user (
              name
          )
        """)
        .eq('user_id', _supabase.auth.currentUser?.id)
        .order("created_at", ascending: false)
        .execute();

    if(res.error != null) {
      final error = res.error;
      change(null, status: RxStatus.error(error.toString()));
      return;
    }

    var places = <Place>[];
    final data = res.data;
    for (var el in (data as List<dynamic>)) {
      var details = await googlePlace.details.get(el["place_id"]);
      places.add(
          Place(
              id: details?.result?.placeId ?? "",
              name: details?.result?.name ?? "",
              openStatus: details?.result?.openingHours?.openNow,
              rating: details!.result!.rating!,
              address: details.result?.vicinity ?? "",
              lat: details.result!.geometry!.location!.lat!,
              lng: details.result!.geometry!.location!.lng!,
              photos: details.result?.photos?.map<String>((ell) => ell.photoReference!).toList())
      );
    }

    change(places, status: RxStatus.success());
  }

  Future<bool> addBookmark(Place place) async {
    // find exists
    final res = await _supabase
        .from('place_bookmark')
        .select()
        .eq('place_id', place.id)
        .eq('user_id', _supabase.auth.currentUser?.id)
        .execute(count: CountOption.exact);

    if(res.error != null){
      return false;
    }

    if(res.count != null && res.count! > 0){
      return true;
    }

    final insertRes = await _supabase
        .from('place_bookmark')
        .insert([
      {'place_id': place.id, "user_id": _supabase.auth.currentUser?.id}
    ]).execute();

    if(insertRes.error != null) {
      return false;
    }

    state?.add(place);
    change(state, status: RxStatus.success());

    return true;
  }

  removeBookmark(Place place) async {
    final res = await _supabase
        .from('place_bookmark')
        .delete()
        .match({'place_id': place.id, "user_id": _supabase.auth.currentUser?.id})
        .execute();

    if(res.error != null) {
      return;
    }

    state?.removeWhere((p) => p.id == place.id);
    change(state, status: RxStatus.success());
  }

  clearLocalBookmark(){
    change([], status: RxStatus.success());
  }
}