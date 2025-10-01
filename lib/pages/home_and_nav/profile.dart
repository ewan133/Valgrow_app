import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/singel_text_alert.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/profile_components/details_box.dart';
import 'package:valgrow_ui/models/store_profile.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controllers for edit input
  final TextEditingController _phoneEditController = TextEditingController();
  final TextEditingController _storeNameEditController =
      TextEditingController();

  // auth service instance
  final _auth = AuthService();

  // database provider instance
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  UserProfile? user;
  StoreProfile? store;

  bool _isLoading = true;

  // Color palette constants
  static const Color primaryGreen = Color(0xFF14AE5C);
  static const Color backgroundColor = Color(0xFFF6F6F6);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardBackground = Colors.white;

  @override
  void initState() {
    super.initState();
    user = Provider.of<DatabaseProvider>(context, listen: false).user;
    store = Provider.of<DatabaseProvider>(context, listen: false).store;
    setState(() {
      _isLoading = false;
    });
  }

  // show edit profile dialog
  void showPhoneEdittingBox() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<DatabaseProvider>(
          builder: (context, databaseProvider, child) {
            final user = databaseProvider.user;

            // If user is null, show a loading state or handle accordingly
            if (user == null) {
              return Center(child: CircularProgressIndicator(color: primaryGreen));
            }

            return MySingelTextAlert(
              editingController: _phoneEditController,
              hintText: _isLoading ? "Loading..." : user.phone,
              onpressedText: "Save",
              onPressed: savePhone,
              maxChar: 11,
            );
          },
        );
      },
    );
  }

  void showStoreNameEdittingBox() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<DatabaseProvider>(
          builder: (context, databaseProvider, child) {
            final store = databaseProvider.store;

            // If store is null, show a loading state or handle accordingly
            if (store == null) {
              return Center(child: CircularProgressIndicator(color: primaryGreen));
            }

            return MySingelTextAlert(
              editingController: _storeNameEditController,
              hintText: _isLoading ? "Loading..." : store.name,
              onpressedText: "Save",
              onPressed: saveStoreName,
              maxChar: 50,
            );
          },
        );
      },
    );
  }

  // save phone number
  Future<void> savePhone() async {
    // Validate phone number using RegExp (e.g., starts with 0 followed by 10 digits)
    final phone = _phoneEditController.text;
    final phoneRegExp = RegExp(r'^0\d{10}$');
    if (!phoneRegExp.hasMatch(phone)) {
      _showSnackBar(
        'Please enter an 11-digit phone number starting with 09',
        isError: true,
      );
      return;
    }
    await databaseProvider.updateUser(phone: phone);
  }

  // save store name
  Future<void> saveStoreName() async {
    // Validate that the store name is at least 8 characters long
    final storeName = _storeNameEditController.text;
    if (storeName.length < 3) {
      _showSnackBar(
        'Store name must be at least 3 characters long',
        isError: true,
      );
      return;
    }

    await databaseProvider.updateStoreName(storeName);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: cardBackground),
        ),
        backgroundColor: isError ? Colors.red : primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> resetPassWithEmail() async {
    bool confirm = await _showConfirmationDialog(
      title: "Reset Password",
      content: "Are you sure you want to reset your password?",
    );
    if (!confirm) return;

    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetEmail(user!.email);
      Fluttertoast.showToast(
        msg: "Password reset email sent to ${user!.email}!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to send reset email: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    bool confirm = await _showConfirmationDialog(
      title: "Logout",
      content: "Are you sure you want to logout?",
    );
    if (!confirm) return;
    await _auth.signout();
  }

  Future<bool> _showConfirmationDialog(
      {required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              content,
              style: TextStyle(color: textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Confirm",
                  style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildProfileDetail({
    required String label,
    required String value,
    VoidCallback? onTap,
    bool editable = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        color: textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (editable)
                Icon(
                  Icons.edit_outlined,
                  color: primaryGreen,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? primaryGreen,
          foregroundColor: textColor ?? cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          // Access the user and store data from the provider
          final user = databaseProvider.user;
          final store = databaseProvider.store;

          if (user == null || store == null) {
            return Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 40),
                // Profile Header Section
                Container(
                  width: double.infinity,
                  color: backgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        _isLoading ? "Loading..." : user.name,
                        style: TextStyle(
                          fontSize: 24,
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isLoading ? "Loading..." : user.role,
                        style: TextStyle(
                          fontSize: 16,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Details Section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: backgroundColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Details',
                          style: TextStyle(
                            fontSize: 18,
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        
                        _buildProfileDetail(
                          label: "Email",
                          value: _isLoading ? "Loading..." : user.email,
                        ),
                        
                        Container(
                          height: 1,
                          color: backgroundColor,
                          margin: EdgeInsets.symmetric(vertical: 6),
                        ),
                        
                        _buildProfileDetail(
                          label: "Phone number",
                          value: _isLoading ? "Loading..." : user.phone,
                          onTap: showPhoneEdittingBox,
                          editable: true,
                        ),
                        
                        Container(
                          height: 1,
                          color: backgroundColor,
                          margin: EdgeInsets.symmetric(vertical: 6),
                        ),
                        
                        _buildProfileDetail(
                          label: "Affiliated Store",
                          value: _isLoading ? "Loading..." : store.name,
                          onTap: (!_isLoading && user.role == "Store Owner")
                              ? showStoreNameEdittingBox
                              : null,
                          editable: !_isLoading && user.role == "Store Owner",
                        ),
                      ],
                    ),
                  ),
                ),

                // Actions Section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: backgroundColor,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Actions',
                          style: TextStyle(
                            fontSize: 18,
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: _buildActionButton(
                            text: "Store Promotion",
                            onPressed: () {
                              Navigator.pushNamed(context, '/store_promotion_list');
                            },
                            backgroundColor: primaryGreen,
                            textColor: cardBackground,
                          ),
                        ),
                        
                        SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                text: "Change Password",
                                onPressed: resetPassWithEmail,
                                backgroundColor: primaryGreen.withOpacity(0.1),
                                textColor: primaryGreen,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                text: "Logout",
                                onPressed: _logout,
                                backgroundColor: textPrimary,
                                textColor: cardBackground,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}