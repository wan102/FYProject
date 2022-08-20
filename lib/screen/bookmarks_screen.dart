import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/sb/auth_state.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import '../controller/bookmark_controller.dart';
import 'details_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends AuthState<BookmarksScreen> with AutomaticKeepAliveClientMixin {
  final GooglePlace _googlePlace = Get.find<GooglePlace>();
  BookmarkController _bookmarkController = Get.find<BookmarkController>();
  signInWithGoogle() async {
    authController.signInWithGoogle();
  }
  
  @override
  void initState() {
    _bookmarkController.bookmarks();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(child:  Obx(() {
      if(authController.isLoggedIn.value != true){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(8),
                child: SignInButton(
                  Buttons.GoogleDark,
                  mini: false,
                  onPressed: () { authController.signInWithGoogle();},
                ),
              ),
            ),
          ],
        );
        //
        // return TextButton(onPressed: () async {
        //   final res = await supabase.auth.signOut();
        // }, child: Text("Sign out"));
      }


        return Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: _bookmarkController.obx((state) {
                  if(state == null || state.isEmpty){
                    return Center(child: Container(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark),
                        Text("No Bookmarks"),
                      ],
                    ),));
                  }
                    return GridView.count(
                      // Create a grid with 2 columns. If you change the scrollDirection to
                      // horizontal, this produces 2 rows.
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      // Generate 100 widgets that display their index in the List.
                      children: List.generate(state.length, (index) {
                        return Material(
                          color: Colors.transparent,
                          elevation: 2,
                          borderRadius: BorderRadius.circular(8.0),
                          child: InkWell(
                            onTap: (){
                              Get.to(()=>DetailsHomeScreen(dest: state[index],));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: NetworkImage("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${state[index].photos![0]}&key=${_googlePlace.apiKEY}"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Container(
                                          color: Colors.white.withOpacity(0.8),
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            state[index].name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Center(
                                    child: ElevatedButton.icon(onPressed: (){
                                      _bookmarkController.removeBookmark(state[index]);
                                    }, icon: Icon(Icons.close), label: Text("Remove"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white),),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }
                ),
              ),
            ),
          ],
        );
      }
    ),);
  }

  @override
  bool get wantKeepAlive => true;
}
