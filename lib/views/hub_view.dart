// lib/views/hub_view.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../controllers/auth_controller.dart'; // Ensure AuthService is defined in this file
import '../models/user_model.dart';
import 'login_view.dart'; // For logout
import '../views/rating_view.dart'; // Added import for RatingView

// Import conditional views (defined in section 2)
import '../views/motorista_hub.dart';
import '../views/passageiro_hub.dart';

class HubView extends StatefulWidget {
  const HubView({super.key});

  @override
  State<HubView> createState() => _HubViewState();
}

class _HubViewState extends State<HubView> {
  late final AuthService _authService; // Declare with late keyword
  User? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(); // Initialize AuthService in initState
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // If no Firebase user, go back to login
      if (mounted) { // This check is already present
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      }
      return;
    }

    // Fetch the complete profile (with role) from Firestore
    final profile = await _authService.fetchUserFromFirestore(firebaseUser.uid);

    // This setState should always be attempted to update _isLoading,
    // and setState itself handles the mounted check internally.
    if (mounted) { // Keep this mounted check to avoid calling setState on a disposed widget
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    }

    if (profile == null) {
      // If Auth account exists but Firestore profile is missing, it’s a critical error.
      _authService.signOut(); // signOut doesn't need context, so it's safe outside mounted check
      if (mounted) { // Added missing mounted check here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: User profile not found in database.')),
        );
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginView()));
      }
      return;
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_userProfile != null) {
      // Conditional Rendering
      if (_userProfile!.role == 'motorista') {
        content = MotoristaHub(user: _userProfile!);
      } else {
        // 'passageiro'
        content = PassageiroHub(user: _userProfile!);
      }
    } else {
      content = const Center(child: Text('Error loading profile.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_userProfile?.role == 'motorista'
            ? 'Motorista Hub'
            : 'Passageiro Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star), // Added a temporary star icon button
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RatingView(
                    tripId: 'dummy_trip_id_123',
                    fromUserId: 'dummy_rater_id_456',
                    toUserId: 'dummy_rated_user_id_789',
                    toUserName: 'Dummy User',
                  ),
                ),
              );
            },
            tooltip: 'Rate (Test)',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: content,
    );
  }
}