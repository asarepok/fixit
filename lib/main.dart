import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_provider.dart';
void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

  );


  runApp(
  const ProviderScope(
    child: FixItGHApp(),
  ),
);

}

class FixItGHApp extends ConsumerWidget {

  const FixItGHApp({
    super.key,
  });


  @override
 Widget build(BuildContext context, WidgetRef ref) {

    return MaterialApp.router(

  debugShowCheckedModeBanner: false,

  title: "FixIt GH",

  theme: AppTheme.lightTheme,

  darkTheme: ThemeData.dark(),

  themeMode: ref.watch(themeProvider),

  routerConfig: appRouter,

);

  }

}