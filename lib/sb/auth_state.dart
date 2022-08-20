import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:maps_app/controller/profile_controller.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controller/auth_controller.dart';
import '../controller/bookmark_controller.dart';

class AuthState<T extends StatefulWidget> extends SupabaseAuthState<T> {
  AuthController authController = Get.find<AuthController>();
  BookmarkController _bookmarkController = Get.find<BookmarkController>();
  ProfileController _profileController = Get.find<ProfileController>();

  @override
  void onUnauthenticated() {
    authController.isLoggedIn.value = false;
  }

  @override
  void onAuthenticated(Session session) {
    authController.isLoggedIn.value = true;
    _bookmarkController.bookmarks();
    _profileController.fetchProfile();
  }

  @override
  void onPasswordRecovery(Session session) {}

  @override
  void onErrorAuthenticating(String message) {}
}