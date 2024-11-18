import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aimemosnap/screens/splash_screen.dart';
import 'package:aimemosnap/providers/diary_provider.dart';
import 'package:aimemosnap/providers/auth_provider.dart' as app_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:aimemosnap/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'memosnap',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      Firebase.app('memosnap');
      print('Existing Firebase app found');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(),
        ),
        ChangeNotifierProxyProvider<app_auth.AuthProvider, DiaryProvider>(
          create: (context) => DiaryProvider(),
          update: (_, auth, previousDiaryProvider) {
            final diaryProvider = previousDiaryProvider ?? DiaryProvider();
            if (auth.user != null) {
              diaryProvider.subscribeToUserDiaries(auth.user!.uid);
            } else {
              diaryProvider.unsubscribeFromUserDiaries();
            }
            return diaryProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'MemoSnap',
        theme: ThemeData(
          primaryColor: const Color(0xFF004D40),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.teal,
          ).copyWith(
            secondary: const Color(0xFF1E88E5),
            background: Colors.white,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.notoSansTextTheme(),
          scaffoldBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF004D40), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}