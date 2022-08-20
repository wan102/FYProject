import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/controller/search_result_controller.dart';
import 'package:maps_app/sb/auth_state.dart';
import 'package:maps_app/screen/bookmarks_screen.dart';
import 'package:maps_app/screen/main_maps_screen.dart';
import 'package:maps_app/screen/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controller/auth_controller.dart';
import 'controller/bookmark_controller.dart';
import 'controller/directions_controller.dart';
import 'controller/maps_controller.dart';
import 'controller/profile_controller.dart';
import 'controller/search_controller.dart';



const supabaseUrl = "";
const supabaseAnonKey = "";
const googleMapsKey = "";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  Get.put(GooglePlace(googleMapsKey));
  Get.put(DirectionsService.init(googleMapsKey));
  Get.put(Supabase.instance.client);
  Get.put(ProfileController());
  Get.put(BookmarkController());
  Get.put(AuthController());
  Get.put(MapsController());
  Get.put(SearchResultController());
  Get.put(SearchController());
  Get.put(DirectionsController());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends AuthState<MyApp> {
  @override
  void initState() {
    recoverSupabaseSession();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.grey,
      ),
      home: const MainNav(),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({Key? key}) : super(key: key);

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var tabScreen = [const MainMapScreen(), const BookmarksScreen(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tabScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
