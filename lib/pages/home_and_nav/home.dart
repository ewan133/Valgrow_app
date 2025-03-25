import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/pages/authpages/document_waiting.dart';
import 'package:valgrow_ui/pages/authpages/verification.dart';
import 'package:valgrow_ui/pages/history/history.dart';
import 'package:valgrow_ui/pages/home_and_nav/dashboard.dart';
import 'package:valgrow_ui/pages/home_and_nav/profile.dart';
import 'package:valgrow_ui/pages/home_and_nav/settings.dart';
import 'package:valgrow_ui/pages/unknown_user/add_store_code.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Instance of AuthService
  final _auth = AuthService();

// Initial index for the bottom navigation bar
  int _selectedIndex = 1;

// Initialize _pages with default empty pages to prevent late initialization errors
  late List<Widget> _pages = [
    Center(child: CircularProgressIndicator()), // Placeholder while loading
    Center(child: CircularProgressIndicator()), // Placeholder while loading
    Center(child: CircularProgressIndicator()), // Placeholder while loading
  ];

// Database provider (moved initialization to initState)
  late DatabaseProvider databaseProvider;

  UserProfile? user;

  @override
  void initState() {
    super.initState();

    // Initialize database provider correctly
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  Future<void> _initializeUserData() async {
    if (!mounted) return;

    try {
      final String? uid = _auth.getUserUid();
      if (uid == null) throw Exception("User ID not found");

      // Fetch user data using Provider
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.fetchUserProfile(uid);


      final user = databaseProvider.user;
      await databaseProvider.fetchStoreProfile(user!.storeId);
      await databaseProvider.fetchItemsByStoreId();
      await databaseProvider.fetchCustomersByStoreId();

      if (user.storeId == null || user.storeId.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddStoreCodePage(),
          ),
        );
      }

      // ✅ Handle navigation based on user verification status
      // if (user.status == 'Unverified' && user.document.isEmpty) {
      //   print('User not verified');

      //   // Close any existing loading dialogs before navigating
      //   if (mounted) {
      //     Navigator.of(context, rootNavigator: true)
      //         .popUntil((route) => route.isFirst);
      //   }

      //   // Delay navigation to avoid black screen issues
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (mounted) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => ImageSubmissionPage(uid: uid),
      //         ),
      //       );
      //     }
      //   });

      //   return; // Stop further execution
      // } else if (user.status == 'Pending') {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     if (mounted) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => DocumentVerificationPage(),
      //         ),
      //       );
      //     }
      //   });

      //   return; // Stop further execution
      // }

      // ✅ Set pages for navigation
      if (mounted) {
        setState(() {
          _pages = [
            ProfilePage(uid: uid),
            DashboardPage(),
            HistoryPage(),
          ];
        });
      }
    } catch (e, stackTrace) {
      print("Error initializing user data: $e\n$stackTrace");
    }
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change the displayed page
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      // bottom nav bar
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        backgroundColor: Colors.white,
        color: Color(0xFF14AE5C),
        height: 70,
        items: [
          CurvedNavigationBarItem(
              child: Icon(
                Icons.person,
                size: 35,
              ),
              label: 'Profile',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
          CurvedNavigationBarItem(
              child: Icon(
                Icons.home,
                size: 35,
              ),
              label: 'Home',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
          CurvedNavigationBarItem(
              child: Icon(
                Icons.history,
                size: 35,
              ),
              label: 'History',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              )),
        ],
        onTap: _onNavBarTapped, // Handle button tap
      ),
    );
  }
}
