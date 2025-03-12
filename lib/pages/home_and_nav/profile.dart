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

  @override
  void initState() {
    super.initState();
    user = Provider.of<DatabaseProvider>(context, listen: false).user;
    store = Provider.of<DatabaseProvider>(context, listen: false).store;
    setState(() {
      _isLoading = false;
    });
  }

  // load user profile

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
              return Center(child: CircularProgressIndicator());
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
              return Center(child: CircularProgressIndicator());
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter an 11-digit phone number starting with 09'),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store name must be at least 8 characters long'),
        ),
      );
      return;
    }

    await databaseProvider.updateStoreName(storeName);
  }

  // reset password method
  Future<void> resetPassWithEmail() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _auth.sendPasswordResetEmail(user!.email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: MyAppbar(title: "User Profile"),
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          // Access the user and store data from the provider
          final user = databaseProvider.user;
          final store = databaseProvider.store;

          if (user == null || store == null) {
            // You can show a loading state or error message if user or store data is null
            return Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60, // Adjust size as needed
                                backgroundColor: Colors
                                    .white, // Background color for the circle
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size:
                                      80, // Adjust icon size within the circle
                                  color: Colors.black54, // Icon color
                                ),
                              ),
                              MyText(
                                text: _isLoading ? "Loading..." : user.name,
                                fontSize: 28,
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 15),
                        // Expanded Details Container takes all remaining space
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  MyProfileDetails(
                                    label: "Email",
                                    value:
                                        _isLoading ? "Loading..." : user.email,
                                    onTap: () {},
                                  ),
                                  Divider(),
                                  MyProfileDetails(
                                    label: "Phone number",
                                    value:
                                        _isLoading ? "Loading..." : user.phone,
                                    onTap: showPhoneEdittingBox,
                                    editable: true,
                                  ),
                                  Divider(),
                                  MyProfileDetails(
                                    label: "Affiliated Store",
                                    value:
                                        _isLoading ? "Loading..." : store.name,
                                    onTap: (!_isLoading &&
                                            user.role == "Store Owner")
                                        ? showStoreNameEdittingBox
                                        : null,
                                    editable: !_isLoading &&
                                        user.role == "Store Owner",
                                  ),
                                  Divider(),
                                  MyProfileDetails(
                                    label: "Role",
                                    value:
                                        _isLoading ? "Loading..." : user.role,
                                    onTap: () {},
                                  ),
                                  Divider(),
                                  if (!_isLoading && user.role == "Store Owner")
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Store Code Text
                                        Expanded(
                                          child: MyProfileDetails(
                                            label: "Store Code",
                                            value: store.storeCode,
                                            onTap:
                                                () {}, // No need for tap action
                                          ),
                                        ),

                                        // Copy Button
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: store.storeCode));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      "Store Code Copied!")),
                                            );
                                          },
                                          icon: Icon(Icons.copy,
                                              color: Colors.blueAccent),
                                          tooltip: "Copy Store Code",
                                        ),

                                        // Regenerate Button

                                        IconButton(
                                          onPressed: () async {
                                            bool confirm = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                      "Regenerate Store Code"),
                                                  content: Text(
                                                      "Are you sure you want to generate a new store code?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: Text("Confirm",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm == true) {
                                              await databaseProvider
                                                  .updateStoreCode();
                                              Fluttertoast.showToast(
                                                msg:
                                                    "New Store Code Generated!",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                            }
                                          },
                                          icon: Icon(Icons.refresh,
                                              color: Colors.green),
                                          tooltip: "Regenerate Store Code",
                                        ),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: MyButton(
                                          text: "Change Password",
                                          color: Colors.blueAccent,
                                          borderRadius: 25,
                                          onTap: resetPassWithEmail,
                                          width: double.infinity,
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      Expanded(
                                        child: MyButton(
                                          width: double.infinity,
                                          text: "Logout",
                                          color: Colors.redAccent,
                                          borderRadius: 25,
                                          onTap: () async {
                                            await _auth.signout();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
