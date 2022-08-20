import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/controller/commnets_controller.dart';
import 'package:maps_app/screen/directions_screen.dart';
import 'package:share/share.dart';

import '../controller/bookmark_controller.dart';
import '../model/place.dart';
import '../sb/auth_state.dart';
class DetailsHomeScreen extends StatefulWidget {
  final Place dest;
  const DetailsHomeScreen({Key? key, required this.dest}) : super(key: key);

  @override
  State<DetailsHomeScreen> createState() => _DetailsHomeScreenState();
}

class _DetailsHomeScreenState extends State<DetailsHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.dest.name),
            elevation: 0,
            backgroundColor: Colors.white,
            bottom: const TabBar(
              tabs: [
                Tab(text: "Info",),
                Tab(text: "Reviews",),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              DetailsHomeTab(dest: widget.dest),
              CommentsTab(dest: widget.dest),
            ],
          ),
        ),
    );
  }
}

class DetailsHomeTab extends StatefulWidget {
  final Place dest;

  const DetailsHomeTab({Key? key, required this.dest}) : super(key: key);

  @override
  State<DetailsHomeTab> createState() => _DetailsHomeTabState();
}

class _DetailsHomeTabState extends AuthState<DetailsHomeTab> with AutomaticKeepAliveClientMixin {
  final GooglePlace _googlePlace = Get.find<GooglePlace>();
  final BookmarkController _bookmarkController = Get.find<BookmarkController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Builder(
                      builder: (context) {
                        if(widget.dest.photos == null) {
                          return Container();
                        }

                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: CarouselSlider(
                            options: CarouselOptions(height: MediaQuery.of(context).size.height / 5),
                            items: widget.dest.photos?.map((el) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                      child: Material(
                                          elevation: 6,
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                              image: DecorationImage(
                                                image: NetworkImage("https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=$el&key=${_googlePlace.apiKEY}"),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )));
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }
                    ),
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
                                  Text(widget.dest.name.toString()),
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
                                  Text("Status", style: Theme.of(context).textTheme.titleSmall,),
                                  Text(widget.dest.openStatus == true ? "Open": "Closed"),
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
                                  Text("Rating", style: Theme.of(context).textTheme.titleSmall,),
                                  Text(widget.dest.rating.toString()),
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
                                  Text("Address", style: Theme.of(context).textTheme.titleSmall,),
                                  Text(widget.dest.address),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],),
                ),
              ),
              SizedBox(
                height: 160,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(target: LatLng(widget.dest.lat, widget.dest.lng),zoom: 18),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  markers: {Marker(markerId: MarkerId("loc"), position: LatLng(widget.dest.lat, widget.dest.lng), onTap: (){Get.to(()=>DirectionsScreen(dest: widget.dest,));})},
                  onTap: (pos){
                    Get.to(()=>DirectionsScreen(dest: widget.dest,));
                  },),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(onPressed: () async {
                    if(authController.isLoggedIn.value == false){
                      if(await authController.signInWithGoogle() == false) {
                        return;
                      }
                    }

                    if(await _bookmarkController.addBookmark(widget.dest)){
                      final snackBar = SnackBar(
                        content: const Text('The place has been bookmarked!'),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  }, icon: Icon(Icons.bookmark), label: Text("Bookmark"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white),),),
                  ElevatedButton.icon(onPressed: () async {
                    await Share.share("${widget.dest.name}\n\n${widget.dest.address}", subject: widget.dest.name);
                  }, icon: Icon(Icons.share), label: Text("Share"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white),),),
                ],
              )
            ],
          ),
        );
  }

  @override
  bool get wantKeepAlive => true;
}

class CommentsTab extends StatefulWidget {
  final Place dest;
  const CommentsTab({Key? key, required this.dest}) : super(key: key);

  @override
  State<CommentsTab> createState() => _CommentsTabState();
}

class _CommentsTabState extends AuthState<CommentsTab> with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late CommentsController _commentsController;
  String comment = "";

  @override
  void initState() {
    _commentsController = CommentsController(widget.dest.id);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (authController.isLoggedIn.value != true) {
                return Container();
              }

              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Comments'
                      ),
                      onSaved: (String? value){comment=value?? "";},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the comments';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            _commentsController.addComments(comment);
                          }
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                );
              }
            ),
            Expanded(
              child: _commentsController.obx((state){
                if (state!.isEmpty){
                  return Container(child: Text("No Reviews"),);
                }
                return ListView.builder(
                    itemCount: state.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: Text(state[index].comment, style: TextStyle(fontSize: 20),),
                        subtitle: Text("${state[index].name} - ${state[index].createdAt}"),
                      );
                    });
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
