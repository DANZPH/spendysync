import 'package:project/pages/auth/signup_page.dart';
import 'package:project/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:project/pages/auth/login_page.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg-final.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Spendysync",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: white,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                Text(
                  "Track your Expenses, Online!",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 30),

                // **Login with Email Button (Square)**
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // **Square Shape**
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18),
                      elevation: 5,
                    ),
                    child: Text(
                      "Login with Email",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // **Signup Button (Outlined, Square)**
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero, // **Square Shape**
                      ),
                      padding: EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // **Terms & Privacy (Centered)**
                Center(
                  child: Text(
                    "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}