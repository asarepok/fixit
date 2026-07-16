import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../services/location_service.dart';
import '../../../../services/database_service.dart';
import '../../../../services/distance_service.dart';


class NearbyArtisansPage extends StatefulWidget {

  const NearbyArtisansPage({super.key});


  @override
  State<NearbyArtisansPage> createState() =>
      _NearbyArtisansPageState();

}



class _NearbyArtisansPageState 
extends State<NearbyArtisansPage>{


final LocationService locationService =
    LocationService();


final DatabaseService databaseService =
    DatabaseService();


final DistanceService distanceService =
    DistanceService();



List<Map<String,dynamic>> artisans = [];

bool loading = true;



@override
void initState(){

super.initState();

loadNearbyArtisans();

}



Future<void> loadNearbyArtisans() async {


try{


final position =
await locationService.getCurrentLocation();



final allArtisans =
await databaseService.getArtisans();



List<Map<String,dynamic>> nearby = [];



for(var artisan in allArtisans){


if(
artisan["latitude"] != null &&
artisan["longitude"] != null
){


double distance =
distanceService.calculateDistance(

position.latitude,

position.longitude,

artisan["latitude"],

artisan["longitude"],

);



artisan["distance"] = distance;



nearby.add(artisan);



}


}



nearby.sort(
(a,b)=>
a["distance"]
.compareTo(
b["distance"],
)
);



setState((){

artisans = nearby;

loading = false;

});



}catch(e){


setState((){

loading=false;

});


}



}



@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title:
const Text(
"Nearby Artisans",
),

),



body:

loading

?

const Center(
child:CircularProgressIndicator(),
)



:

artisans.isEmpty

?

const Center(
child:Text(
"No artisans nearby",
),
)



:

ListView.builder(

padding:
const EdgeInsets.all(20),


itemCount:
artisans.length,


itemBuilder:(context,index){


final artisan =
artisans[index];



return Card(

child:ListTile(


leading:
const CircleAvatar(

child:
Icon(
Icons.handyman,
),

),


title:
Text(
artisan["name"] ??
"Unknown Artisan",
),



subtitle:
Text(

"${artisan["distance"].toStringAsFixed(2)} km away",

),



trailing:
const Icon(
Icons.arrow_forward_ios,
),


),


);


},


),



);


}


}