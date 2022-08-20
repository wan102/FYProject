class Place {
  String id;
  String name;
  bool? openStatus;
  double rating;
  String address;
  double lat;
  double lng;
  List<String>? photos;
  Place({required this.id, required this.name, required this.openStatus, required this.rating, required this.address, required this.lat, required this.lng, this.photos});
}