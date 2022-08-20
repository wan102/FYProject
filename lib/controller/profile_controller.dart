import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile {
  String name;
  String email;
  Profile({required this.name, required this.email});
}

class ProfileController extends GetxController with StateMixin<Profile> {
  final _supabase = Get.find<SupabaseClient>();

  ProfileController(){
    fetchProfile();
  }

  fetchProfile() async {
    final res = await _supabase
        .from('user')
        .select()
        .eq('id', _supabase.auth.currentUser?.id)
        .execute(count: CountOption.exact);


    if(res.count == null || res.count == 0) {
      return false;
    }

    var data = (res.data as List<dynamic>)[0];

    change(Profile(name: data["name"], email: data["email"]), status: RxStatus.success());
  }

}