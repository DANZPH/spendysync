// ignore_for_file: deprecated_member_use

import 'package:project/pages/onboarding_page.dart';
import 'package:project/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  bool isLoading = true;
  String fullName = "";
  String email = "";
  String profileImage = "";
  String bio = "";
  String address = ""; // ✅ Added Address Field

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not logged in!")),
      );
      return;
    }

    try {
      final response = await supabase
          .from('users')
          .select(
              'full_name, email, profile_image, bio, address') // ✅ Fetch Address
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No profile found. Please update your details.")),
        );
        return;
      }

      final String newImageUrl = supabase.storage
          .from('profile_pictures')
          .getPublicUrl('profiles/${user.id}.jpg');

      if (mounted) {
        setState(() {
          fullName = response['full_name'] ?? "Unknown User";
          email = response['email'] ?? "No Email";
          profileImage = response['profile_image'] ?? newImageUrl;
          bio = response['bio'] ?? "No bio available";
          address =
              response['address'] ?? "No address available"; // ✅ Store Address
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
      );
      setState(() => isLoading = false);
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );

    // ✅ If `true` is returned, refresh the profile data
    if (result == true) {
      fetchUserProfile();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : getBody(),
    );
  }

  Widget getBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Background Image
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/prof-header.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: 0,
                right: 0,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondary1,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(5),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : const AssetImage(
                                      "assets/images/default_avatar.png")
                                  as ImageProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 70),

          // Display User Name & Bio
          Text(
            fullName,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            bio,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // Profile Options
          _buildOption(
            Icons.edit,
            "Edit Profile",
            _navigateToEditProfile,
          ),
          _buildOption(Icons.lock, "Change Password", () {
            _showChangePasswordDialog();
          }),

          const SizedBox(height: 30),

          // Log Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  const Text("Sign Out", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12), // Rounded Corners
            border: Border.all(
                color: Colors.grey.withOpacity(0.3)), // Subtle Border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05), // Soft Shadow
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: secondary1.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: secondary1, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Change Password",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Old Password",
                      labelStyle: TextStyle(color: Colors.white))),
              TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: TextStyle(color: Colors.white))),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel",
                    style: TextStyle(color: Colors.white))),
            ElevatedButton(onPressed: () {}, child: const Text("Update")),
          ],
        );
      },
    );
  }
}
