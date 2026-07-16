import 'package:flutter/material.dart';


class ManageUsersScreen extends StatelessWidget {

  const ManageUsersScreen({super.key});


  @override
  Widget build(BuildContext context) {

    final users = [
      "Kwame Mensah",
      "Ama Owusu",
      "Kojo Asare",
      "Akosua Boateng",
    ];


    return Scaffold(

      appBar: AppBar(
        title: const Text("Manage Users"),
      ),


      body: ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: users.length,

        itemBuilder: (context,index){

          return Card(

            child: ListTile(

              leading: const CircleAvatar(

                child: Icon(Icons.person),

              ),

              title: Text(users[index]),

              subtitle:
              const Text("Customer Account"),

              trailing: PopupMenuButton(

                itemBuilder: (context)=>[

                  const PopupMenuItem(
                    value:"block",
                    child: Text("Block User"),
                  ),

                  const PopupMenuItem(
                    value:"delete",
                    child: Text("Delete User"),
                  ),

                ],

              ),

            ),

          );

        },

      ),

    );

  }

}