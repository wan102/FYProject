import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:maps_app/controller/directions_controller.dart';

import '../model/place.dart';

class DirectionsScreen extends StatefulWidget {
  final Place dest;

  const DirectionsScreen({Key? key, required this.dest}) : super(key: key);

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  late final _initialCameraPosition = CameraPosition(target: LatLng(widget.dest.lat, widget.dest.lng), zoom: 14);
  final GooglePlace _googlePlace = Get.find<GooglePlace>();
  final DirectionsController _directionsController = DirectionsController();
  GoogleMapController? _controller;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  var isSrcSelected = false;
  var mode = TravelMode.driving;
  LatLng? startLoc;
  @override
  void initState() {
    _directionsController.directionsRoute.listen((p0) {
      setState(() {
        polylines = {
          Polyline(
            polylineId: PolylineId("route"),
            color: Colors.red,
            width: 4,
            points: _directionsController.directionsRoute.value!.overviewPath!.map<LatLng>((el) => LatLng(el.latitude, el.longitude)).toList(),
          ),
        };
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _directionsController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Directions"),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false, mapToolbarEnabled: false,
                markers: markers,
                polylines: polylines,
                onLongPress: (pos) {
                  if (isSrcSelected) {
                    return;
                  }
                  _directionsController.getRoute(pos.latitude, pos.longitude, widget.dest.lat, widget.dest.lng, mode: mode);
                  startLoc = pos;
                  setState(() {
                    isSrcSelected = true;
                    markers.add(Marker(markerId: MarkerId("src"), position: pos));
                  });
                },
                onMapCreated: onMapCreated),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height / 10, minWidth: MediaQuery.of(context).size.width),
                child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(widget.dest.name, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                                    widget.dest.rating != null
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.black54,
                                              ),
                                              Text(
                                                "${widget.dest.rating}",
                                                style: TextStyle(color: Colors.black54),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    widget.dest.openStatus != null
                                        ? Text(
                                            widget.dest.openStatus == true ? "Open" : "Closed",
                                            style: TextStyle(color: Colors.black54),
                                          )
                                        : Container(),
                                  ],
                                )),
                            Expanded(
                              flex: 1,
                              child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: widget.dest.photos != null && widget.dest.photos!.isNotEmpty
                                            ? NetworkImage(
                                                "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${widget.dest.photos![0]}&key=${_googlePlace.apiKEY}")
                                            : NetworkImage("https://dummyimage.com/1x'1/ffffff/ffffff"),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                        Builder(builder: (context) {
                          if (isSrcSelected) {
                            return Container();
                          }
                          return Container(margin:  EdgeInsets.only(top:8),padding: EdgeInsets.all(8), color: Colors.yellow,child: Text("Please long press the staring point on the Maps."));
                        }),
                      ],
                    )),
              ),
            ),
            Obx(() {
              if (_directionsController.directionsRoute.value == null) {
                return Container();
              }
              return Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Builder(builder: (_){
                      return ElevatedButton.icon(onPressed: (){
                        if(mode == TravelMode.driving){
                          mode = TravelMode.walking;
                        } else {
                          mode = TravelMode.driving;
                        }
                        _directionsController.getRoute(startLoc!.latitude, startLoc!.longitude, widget.dest.lat, widget.dest.lng, mode: mode);
                      }, icon: mode == TravelMode.driving ? Icon(Icons.drive_eta): Icon(Icons.directions_walk), label: mode == TravelMode.driving ? Text("Driving"): Text("Walking"),style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.white),),);
                    }),
                    Container(
                        height: MediaQuery.of(context).size.height / 8,
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(_directionsController.directionsRoute.value!.legs![0].distance!.text!, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                                      Text(_directionsController.directionsRoute.value!.legs![0].duration!.text!, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500)),
                                      Text(mode == TravelMode.driving ? "Driving": "Walking", style: TextStyle(fontSize: 16.0)),
                                    ],
                                  )),
                                  Builder(builder: (context) {
                                    if (widget.dest.photos == null || widget.dest.photos!.length <= 0) {
                                      return Container();
                                    }
                                    return AspectRatio(
                                        aspectRatio: 1,
                                        child: Container(
                                          child: FittedBox(child: mode == TravelMode.driving ? Icon(Icons.drive_eta): Icon(Icons.directions_walk)),
                                        ));
                                  })
                                ],
                              ),
                            ),
                          ],
                        )),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  onMapCreated(controller) {
    _controller = controller;
    setState(() {
      markers.add(Marker(markerId: MarkerId("dest"), position: LatLng(widget.dest.lat, widget.dest.lng)));
    });
  }
}
