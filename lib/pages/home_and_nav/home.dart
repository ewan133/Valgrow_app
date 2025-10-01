import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/pages/history/history.dart';
import 'package:valgrow_ui/pages/home_and_nav/dashboard.dart';
import 'package:valgrow_ui/pages/home_and_nav/profile.dart';
import 'package:valgrow_ui/pages/unknown_user/add_store_code.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Services and providers
  final AuthService _auth = AuthService();
  late DatabaseProvider databaseProvider;

  // Navigation state
  int _selectedIndex = 1;

  // Initialize _pages with professional loading states
  late List<Widget> _pages = [
    _buildLoadingPage(), // Professional loading page
    _buildLoadingPage(), // Professional loading page
    _buildLoadingPage(), // Professional loading page
  ];

  // User data
  UserProfile? user;

  // Professional loading page widget
  Widget _buildLoadingPage() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14AE5C)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Initialize database provider
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    
    // Initialize user data after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeUserData();
    });
  }

  Future<void> _initializeUserData() async {
    if (!mounted) return;

    try {
      final String? uid = _auth.getUserUid();
      if (uid == null) throw Exception("User ID not found");

      // Fetch all required data using Provider
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.fetchUserProfile(uid);
      
      final user = databaseProvider.user;
      await databaseProvider.fetchStoreProfile(user!.storeId);
      await databaseProvider.fetchItemsByStoreId();
      await databaseProvider.fetchCustomersByStoreId();
      await databaseProvider.checkOverdueDebtsForNotifications();
      await databaseProvider.fetchUserNotifications();

      // Navigate to store code page if no store is associated
      if (user.storeId.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddStoreCodePage(),
          ),
        );
        return;
      }

      // Set pages for navigation
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
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          index: _selectedIndex,
          backgroundColor: Colors.transparent,
          color: Color(0xFF14AE5C),
          buttonBackgroundColor: Color(0xFF14AE5C),
          height: 65,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: [
            CurvedNavigationBarItem(
              child: Icon(
                Icons.person_outline,
                size: 28,
                color: Colors.white,
              ),
              label: 'Profile',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            CurvedNavigationBarItem(
              child: Icon(
                Icons.home_outlined,
                size: 28,
                color: Colors.white,
              ),
              label: 'Home',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            CurvedNavigationBarItem(
              child: Icon(
                Icons.history_outlined,
                size: 28,
                color: Colors.white,
              ),
              label: 'History',
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
          onTap: _onNavBarTapped,
        ),
      ),
    );
  }
}
