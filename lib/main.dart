import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/pages/onboarding_page.dart';
import 'package:project/pages/root_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://adtjgytbhzbhpvwaguny.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkdGpneXRiaHpiaHB2d2FndW55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkyMzg1NzEsImV4cCI6MjA1NDgxNDU3MX0.zuMPlDuNqsxUYyRCkfNnG3Ie7Q_e56wqUFCAkizNxVU',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "spendysync",
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _position = 50;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _position = 0;
      });
    });

    // Navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () async {
      final session = Supabase.instance.client.auth.currentSession;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                session != null ? RootApp() : OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          duration: Duration(seconds: 2),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _position, 0), // Slide effect
          child: AnimatedOpacity(
            duration: Duration(seconds: 2),
            opacity: _opacity,
            child: Image.asset(
              "assets/images/splash2.jpg",
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
