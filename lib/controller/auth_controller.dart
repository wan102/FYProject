import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:maps_app/controller/bookmark_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final _supabase = Get.find<SupabaseClient>();
  final _bookmarkController = Get.find<BookmarkController>();
  var isLoggedIn = false.obs;
  GotrueSubscription? _sub;
  AuthController(){
    if(_supabase.auth.currentUser != null) {
      isLoggedIn.value = true;
    }

    _sub = _supabase.auth.onAuthStateChange((event, session) {
      switch(event) {
        case AuthChangeEvent.passwordRecovery:
          break;
        case AuthChangeEvent.signedIn:
          isLoggedIn.value = true;
          break;
        case AuthChangeEvent.signedOut:
          isLoggedIn.value = false;
          break;
        case AuthChangeEvent.tokenRefreshed:
          break;
        case AuthChangeEvent.userUpdated:
          break;
      }
    });
  }

  Future<bool> signInWithGoogle() async {
    final res = await _supabase.auth.signInWithProvider(Provider.google, options: AuthOptions(
        redirectTo: kIsWeb ? null : 'io.supabase.wfyp://login-callback/'));
    return res;
  }

  signOut() async {
    await _supabase.auth.signOut();
    _bookmarkController.clearLocalBookmark();
  }

  @override
  void dispose() {
    _sub?.data?.unsubscribe();
    super.dispose();
  }
}