import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../widgets/primary_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';
import '../../../../models/user_model.dart';


class RegisterPage extends StatefulWidget {

  const RegisterPage({super.key});


  @override
  State<RegisterPage> createState() => _RegisterPageState();

}



class _RegisterPageState extends State<RegisterPage> {


  final AuthService _authService = AuthService();

  final DatabaseService _databaseService = DatabaseService();



  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();



  bool isLoading = false;



  @override
  void dispose() {

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();

  }





  Future<void> registerUser() async {


    if(isLoading) return;



    // Validate fields

    if(
    _nameController.text.trim().isEmpty ||
    _emailController.text.trim().isEmpty ||
    _phoneController.text.trim().isEmpty ||
    _passwordController.text.trim().isEmpty
    ){

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Please fill all fields"),
        ),

      );

      return;

    }



    setState(() {

      isLoading = true;

    });



    try {


      // Create Firebase account

      User? firebaseUser = await _authService.register(

        _emailController.text.trim(),

        _passwordController.text.trim(),

      );



      if(firebaseUser == null){

        throw Exception(
          "Account creation failed",
        );

      }



      // Create user model

      UserModel user = UserModel(

        uid: firebaseUser.uid,

        name: _nameController.text.trim(),

        email: _emailController.text.trim(),

        phone: _phoneController.text.trim(),

        role: "user",

      );




      // Save user data to Firestore

      await _databaseService.createUser(user);




      if(mounted){

        context.push('/role-selection');

      }




    }


    on FirebaseAuthException catch(e){


      if(mounted){

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(

              e.message ??
              "Firebase registration failed",

            ),

          ),

        );

      }


    }



    catch(e){


      if(mounted){

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text(

              e.toString(),

            ),

          ),

        );

      }


    }



    finally{


      if(mounted){

        setState(() {

          isLoading = false;

        });

      }


    }


  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Create Account",
        ),

      ),




      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(20),


          child: ListView(

            children: [



              const SizedBox(height:20),




              TextField(

                controller:_nameController,

                decoration: const InputDecoration(

                  labelText:"Full Name",

                  prefixIcon:
                  Icon(Icons.person),

                ),

              ),




              const SizedBox(height:20),




              TextField(

                controller:_emailController,

                keyboardType:
                TextInputType.emailAddress,


                decoration: const InputDecoration(

                  labelText:"Email",

                  prefixIcon:
                  Icon(Icons.email),

                ),

              ),





              const SizedBox(height:20),





              TextField(

                controller:_phoneController,

                keyboardType:
                TextInputType.phone,


                decoration: const InputDecoration(

                  labelText:"Phone Number",

                  prefixIcon:
                  Icon(Icons.phone),

                ),

              ),





              const SizedBox(height:20),





              TextField(

                controller:_passwordController,

                obscureText:true,


                decoration: const InputDecoration(

                  labelText:"Password",

                  prefixIcon:
                  Icon(Icons.lock),

                ),

              ),





              const SizedBox(height:30),





              isLoading

              ? const Center(

                  child:CircularProgressIndicator(),

                )


              : PrimaryButton(

                  text:"Continue",

                  onPressed:registerUser,

                ),



            ],

          ),

        ),

      ),


    );

  }


}