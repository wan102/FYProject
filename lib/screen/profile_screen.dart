import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:maps_app/controller/profile_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../sb/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends AuthState<ProfileScreen> {
  final _profileController = Get.find<ProfileController>();
  final _supabase = Get.find<SupabaseClient>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (authController.isLoggedIn.value != true) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: SignInButton(
                    Buttons.GoogleDark,
                    mini: false,
                    onPressed: () {
                      authController.signInWithGoogle();
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileController.obx((state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(builder: (context){
                            return Container(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name", style: Theme.of(context).textTheme.titleSmall,),
                                  Text(state?.name ?? ""),
                                ],
                              ),
                            );
                          }),
                          Builder(builder: (context){
                            return Container(
                              padding: EdgeInsets.only(bottom: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Email", style: Theme.of(context).textTheme.titleSmall,),
                                  Text(state?.email ?? ""),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              }
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: TextButton(onPressed: () async {
                final res = await _supabase.auth.signOut();
              }, child: Text("Sign out")),
            ),
          ],
        );
      }),
    );
  }
}
