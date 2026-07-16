import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../widgets/primary_button.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/database_service.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();

}



class _LoginPageState extends State<LoginPage> {


  final AuthService _authService = AuthService();


  final TextEditingController _emailController =
      TextEditingController();


  final TextEditingController _passwordController =
      TextEditingController();



  bool isLoading = false;



  @override
  void dispose() {

    _emailController.dispose();

    _passwordController.dispose();

    super.dispose();

  }





  Future<void> loginUser() async {


    if(isLoading) return;


    setState(() {

      isLoading = true;

    });



    try {


      User? user = await _authService.login(

        _emailController.text.trim(),

        _passwordController.text.trim(),

      );



      if(user != null && mounted){


  String? role =
      await DatabaseService()
          .getUserRole(user.uid);



  if(role == "artisan"){

    context.go('/artisan-dashboard');

  }


  else if(role == "admin"){

    context.go('/admin-dashboard');

  }


  else{

    context.go('/home');

  }


}



    }


    on FirebaseAuthException catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            e.message ?? "Login failed",
          ),

        ),

      );


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

        title:
        const Text("Login"),

      ),



      body: SafeArea(


        child: Padding(

          padding:
          const EdgeInsets.all(20),



          child: Column(


            children:[



              const SizedBox(height:40),




              TextField(

                controller:_emailController,

                keyboardType:
                TextInputType.emailAddress,


                decoration:
                const InputDecoration(

                  labelText:"Email",

                  prefixIcon:
                  Icon(Icons.email),

                ),

              ),




              const SizedBox(height:20),




              TextField(

                controller:_passwordController,

                obscureText:true,


                decoration:
                const InputDecoration(

                  labelText:"Password",

                  prefixIcon:
                  Icon(Icons.lock),

                ),

              ),




              Align(

                alignment:
                Alignment.centerRight,


                child:TextButton(

                  onPressed:(){

                    context.push('/forgot-password');

                  },


                  child:
                  const Text(
                    "Forgot Password?",
                  ),

                ),

              ),




              const SizedBox(height:25),





              isLoading

              ? const CircularProgressIndicator()


              : PrimaryButton(

                  text:"Login",

                  onPressed:loginUser,

                ),





              const SizedBox(height:20),




              Row(

                mainAxisAlignment:
                MainAxisAlignment.center,


                children:[


                  const Text(
                    "Don't have an account?",
                  ),


                  TextButton(

                    onPressed:(){

                      context.push('/register');

                    },


                    child:
                    const Text(
                      "Register",
                    ),

                  ),

                ],

              ),



            ],


          ),


        ),


      ),


    );


  }


}