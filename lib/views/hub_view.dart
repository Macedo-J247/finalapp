// lib/views/hub_view.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as FBAuth;
import '../controllers/auth_controller.dart'; // Ensure AuthService is defined in this file
import '../models/user_model.dart';
import 'login_view.dart'; // For logout

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
    final firebaseUser = FBAuth.FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      // If no Firebase user, go back to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      }
      return;
    }

    // Fetch the complete profile (with role) from Firestore
    final profile = await _authService.fetchUserFromFirestore(firebaseUser.uid);

    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });

    if (profile == null && mounted) {
      // If Auth account exists but Firestore profile is missing, it’s a critical error.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: User profile not found in database.')),
      );
      _authService.signOut();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()));
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
