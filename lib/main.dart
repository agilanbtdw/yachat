import 'package:flutter/material.dart';
import 'package:my_chat_app/pages/splash_page.dart';
import 'package:my_chat_app/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://supabase.agilan.me',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzAyNTc4NjAwLAogICJleHAiOiAxODYwNDMxNDAwCn0.2kOnXQTj_8f4RHpSgt87HxeC7FniUKDhm6nBUkUmLbs',
    realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 30),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget { 
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YAChat',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
