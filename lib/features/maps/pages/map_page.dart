import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../services/location_service.dart';


class MapPage extends StatefulWidget {

  const MapPage({super.key});


  @override
  State<MapPage> createState() => _MapPageState();

}



class _MapPageState extends State<MapPage>{


GoogleMapController? mapController;


final LocationService locationService =
    LocationService();


LatLng? currentLocation;



@override
void initState(){

super.initState();

getLocation();

}



Future<void> getLocation() async {


final position =
await locationService.getCurrentLocation();



setState(() {

currentLocation = LatLng(

position.latitude,

position.longitude,

);

});



if(mapController != null){

mapController!.animateCamera(

CameraUpdate.newLatLngZoom(

currentLocation!,

15,

),

);

}


}




@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title:
const Text(
"FixIt Map",
),

),



body:

currentLocation == null

?

const Center(

child:
CircularProgressIndicator(),

)



:

GoogleMap(


initialCameraPosition:

CameraPosition(

target:
currentLocation!,

zoom:15,

),



onMapCreated:(controller){

mapController = controller;

},



myLocationEnabled:true,

myLocationButtonEnabled:true,



markers:{


Marker(

markerId:
const MarkerId(
"customer",
),


position:
currentLocation!,


infoWindow:
const InfoWindow(

title:
"Your Location",

),


),


},



),



);


}


}