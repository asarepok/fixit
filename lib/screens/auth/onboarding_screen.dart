import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  final PageController controller = PageController();

  int currentIndex = 0;

  final List<Map<String, String>> pages = [

    {
      "title":"Find Skilled Artisans",
      "description":"Search verified plumbers, electricians, mechanics and many more."
    },

    {
      "title":"Book Easily",
      "description":"Request services in just a few taps from anywhere."
    },

    {
      "title":"Reliable Service",
      "description":"Rate artisans and build trust through reviews."
    }

  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: SafeArea(

        child: Column(

          children: [

            Expanded(

              child: PageView.builder(

                controller: controller,

                onPageChanged: (value){

                  setState(() {

                    currentIndex=value;

                  });

                },

                itemCount: pages.length,

                itemBuilder: (_,index){

                  return Padding(

                    padding: const EdgeInsets.all(25),

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.handyman,
                          size: 150,
                          color: Colors.blue.shade700,
                        ),

                        const SizedBox(height:40),

                        Text(

                          pages[index]["title"]!,

                          textAlign: TextAlign.center,

                          style: const TextStyle(

                            fontSize:28,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height:20),

                        Text(

                          pages[index]["description"]!,

                          textAlign: TextAlign.center,

                          style: const TextStyle(

                            fontSize:17,

                            color: Colors.grey,

                          ),

                        ),

                      ],

                    ),

                  );

                },

              ),

            ),

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(

                pages.length,

                (index)=>AnimatedContainer(

                  duration: const Duration(milliseconds:300),

                  margin: const EdgeInsets.all(4),

                  height:10,

                  width: currentIndex==index?25:10,

                  decoration: BoxDecoration(

                    color: currentIndex==index?Colors.blue:Colors.grey,

                    borderRadius: BorderRadius.circular(20),

                  ),

                ),

              ),

            ),

            Padding(

              padding: const EdgeInsets.all(20),

              child: PrimaryButton(

                text: currentIndex==2?"Get Started":"Next",

                onPressed: (){

                  if(currentIndex==2){

                    context.go('/login');

                  }

                  else{

                    controller.nextPage(

                      duration: const Duration(milliseconds:400),

                      curve: Curves.ease,

                    );

                  }

                },

              ),

            )

          ],

        ),

      ),

    );

  }

}