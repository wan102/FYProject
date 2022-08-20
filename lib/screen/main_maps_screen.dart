import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/controller/search_result_controller.dart';
import 'package:maps_app/screen/details_screen.dart';
import 'package:maps_app/screen/directions_screen.dart';
import 'package:maps_app/widget/maps_screen.dart';

import '../controller/maps_controller.dart';
import '../controller/search_controller.dart';

class Category {
  String name;
  String type;
  IconData icon;

  Category({required this.name, required this.type, required this.icon});
}

var defaultCategoryList = [
  Category(name: "Museum", type: "museum", icon: Icons.museum),
  Category(name: "Art Gallery", type: "art_gallery", icon: Icons.camera),
  Category(name: "Park", type: "park", icon: Icons.park_rounded),
  Category(name: "Amusement Park", type: "amusement_park", icon: Icons.park),
  Category(name: "Zoo", type: "zoo", icon: Icons.location_on),
  Category(name: "Restaurant", type: "restaurant", icon: Icons.restaurant),
  Category(name: "Shopping", type: "shopping_mall", icon: Icons.shopping_bag),
  Category(name: "Cafe", type: "Cafe", icon: Icons.local_cafe),
  Category(name: "Stadium", type: "stadium", icon: Icons.stadium),
  Category(name: "Supermarket", type: "supermarket", icon: Icons.shopping_cart),
  Category(name: "Hospital", type: "hospital", icon: Icons.local_hospital),
];

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({Key? key}) : super(key: key);

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _typeAheadController = TextEditingController();

  final MapsController _mapController = Get.find<MapsController>();
  final SearchController _searchController = Get.find<SearchController>();
  final SearchResultController _searchResultController = Get.find<SearchResultController>();
  final GooglePlace _googlePlace = Get.find<GooglePlace>();
  final CarouselController _carouselController = CarouselController();
  @override
  void initState() {
    _searchController.selectedMarkerId.listen(carouselListener);
    super.initState();
  }

  carouselListener(s){
    var i = 0;
    for (var el in _searchResultController.result) {
      if(el.id == s) {
        break;
      }
      i++;
    }
    _carouselController.animateToPage(i);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MainMaps(),
            Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 8, top: 8, right: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(32.0),
                                child: TypeAheadFormField(
                                  hideOnEmpty: true,
                                  textFieldConfiguration: TextFieldConfiguration(
                                    onEditingComplete: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      var coor = await _mapController.centerLatLng();
                                      _searchController.searchText(_typeAheadController.value.text, coor.latitude, coor.longitude);
                                    },
                                    controller: _typeAheadController,
                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.search),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                        enabledBorder: OutlineInputBorder(
                                          // width: 0.0 produces a thin "hairline" border
                                          borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                                          borderRadius: BorderRadius.circular(32.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: Colors.transparent, width: 0),
                                          borderRadius: BorderRadius.circular(32.0),
                                        ),
                                        // suffixIcon: IconButton(
                                        //     onPressed: () => {},
                                        //     icon: Icon(
                                        //       Icons.directions,
                                        //       color: Colors.black,
                                        //     )),
                                        filled: true,
                                        hintStyle: TextStyle(color: Colors.grey[800]),
                                        hintText: "Search",
                                        fillColor: Colors.white),
                                  ),
                                  onSuggestionSelected: (suggestion) {},
                                  itemBuilder: (BuildContext context, Object? suggestion) {
                                    return ListTile(
                                      title: Text(suggestion! as String),
                                    );
                                  },
                                  suggestionsCallback: (String s) {
                                    return [];
                                  },
                                ),
                              ),
                            ),
                            IconButton(onPressed: () => {
                              _mapController.googleMapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target:  _mapController.gpsLocation.value?? LatLng(22.3305586,114.1277085),zoom: 12)))
                            }, icon: Icon(Icons.gps_fixed))
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.only(left: 8),
                            child: Row(
                                children: defaultCategoryList
                                    .map<Widget>(
                                      (el) => Container(
                                    padding: EdgeInsets.only(right: 4),
                                    child: ElevatedButton.icon(
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                            ))),
                                        onPressed: () async {
                                          var coor = await _mapController.centerLatLng();
                                          _searchController.searchNearBy(coor.latitude, coor.longitude, el.type);
                                        },
                                        icon: Icon(el.icon),
                                        label: Text(el.name)),
                                  ),
                                )
                                    .toList()),
                          )),
                    ],
                  ),
                )),
            Positioned(bottom: 16, left: 0, right: 0, child: bottomSuggestion())
          ],
        ),
      ),
    );
  }

  bottomSuggestion() {
    return Obx(() {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(height: MediaQuery.of(context).size.height / 5),
        items: _searchResultController.result.map((el) {
          return Builder(
            builder: (BuildContext context) {
              return InkWell(
                onTap: (){
                  Get.to(()=>DetailsHomeScreen(dest: el,));
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Text(el.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                                              el.rating != null? Row(children: [
                                                Icon(Icons.star, color: Colors.black54,),
                                                Text("${el.rating}", style: TextStyle(color: Colors.black54),),
                                              ],) : Container(),
                                              el.openStatus != null ? Text(el.openStatus == true ? "Open": "Closed", style: TextStyle(color: Colors.black54),) : Container(),
                                            ],
                                          )),
                                      Builder(
                                          builder: (context) {
                                            if(el.photos == null || el.photos!.isEmpty) {
                                              return Container();
                                            }
                                            return AspectRatio(
                                                aspectRatio: 1,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: NetworkImage("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${el.photos![0]}&key=${_googlePlace.apiKEY}"),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ));
                                          }
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                        style: ButtonStyle(
                                            elevation: MaterialStateProperty.all<double>(0),
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                              side: BorderSide(width: 1, color: Colors.black),
                                            ))),
                                        onPressed: () async {
                                          Get.to(()=>DirectionsScreen(dest: el,));
                                        },
                                        icon: Icon(Icons.directions),
                                        label: Text("Directions")),
                                    ElevatedButton.icon(
                                        style: ButtonStyle(
                                            elevation: MaterialStateProperty.all<double>(0),
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(18.0),
                                              side: BorderSide(width: 1, color: Colors.black),
                                            ))),
                                        onPressed: () async {
                                          Get.to(()=>DetailsHomeScreen(dest: el,));
                                        },
                                        icon: Icon(Icons.more_horiz),
                                        label: Text("Details")),
                                  ],)
                              ],
                            )))),
              );
            },
          );
        }).toList(),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
