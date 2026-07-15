import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';


void main() {

  runApp(
    const FixItGHApp(),
  );

}


class FixItGHApp extends StatelessWidget {

  const FixItGHApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(

      debugShowCheckedModeBanner: false,

      title: "FixIt GH",

      theme: AppTheme.lightTheme,

      routerConfig: appRouter,

    );

  }

}