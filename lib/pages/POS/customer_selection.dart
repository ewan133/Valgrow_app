import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';
import 'package:collection/collection.dart';

class CustomerSelectionModal extends StatefulWidget {
  final CustomerDetails? selectedCustomer;
  final Function(CustomerDetails) onItemSelected;

  const CustomerSelectionModal({
    super.key,
    required this.selectedCustomer,
    required this.onItemSelected,
    required String selectedValue,
  });

  @override
  _CustomerSelectionModalState createState() => _CustomerSelectionModalState();
}

class _CustomerSelectionModalState extends State<CustomerSelectionModal> {
  File? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String? _phoneError;
  List<CustomerDetails> _filteredCustomers = [];
  bool _isUploading = false; // ✅ Track upload status

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _fetchCustomers();
    });
  }

  /// ✅ Fetch customers from provider
  void _fetchCustomers() {
    final customers =
        Provider.of<DatabaseProvider>(context, listen: false).customers;
    setState(() {
      _filteredCustomers = customers;
    });
  }

  /// ✅ Filter customers based on search query
  void _filterCustomers(String query) {
    final customers =
        Provider.of<DatabaseProvider>(context, listen: false).customers;

    setState(() {
      _filteredCustomers = query.isEmpty
          ? customers
          : customers
              .where((customer) =>
                  customer.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  /// ✅ Image Picker (Camera or Gallery)
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// ✅ Show Image Picker Options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Show Customer Details Dialog (for Adding a Customer)
  void _showCustomerDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        File? localImage = _selectedImage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> _pickImageInDialog(ImageSource source) async {
              final pickedFile = await ImagePicker().pickImage(source: source);
              if (pickedFile != null) {
                final file = File(pickedFile.path);
                setState(() {
                  _selectedImage = file; // Update parent state
                });
                setDialogState(() {
                  localImage = file; // Update dialog UI
                });
              }
            }

            void _showImagePickerOptionsInDialog() {
              showModalBottomSheet(
                context: context,
                builder: (context) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text("Take a Photo"),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageInDialog(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text("Choose from Gallery"),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImageInDialog(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Customer Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.black.withOpacity(0.7),
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerOptionsInDialog,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF6F6F6),
                              border: Border.all(
                                color: const Color(0xFFF6F6F6),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.transparent,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: localImage == null
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Colors.black.withOpacity(0.5),
                                      size: 24,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Customer Name",
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFF14AE5C)),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F6F6),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: const Color(0xFF14AE5C)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F6F6),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          errorText: _phoneError,
                          counterText: "",
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        onChanged: (value) {
                          _validatePhoneNumber(value);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _handleAddCustomer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF14AE5C),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isUploading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Save",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Function to Validate Phone Number
  bool _validatePhoneNumber(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _phoneError = "Phone number is required";
      } else if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
        _phoneError = "Phone number must be 11 digits and start with 09";
      } else {
        _phoneError = null; // ✅ No errors
      }
    });
    return _phoneError == null;
  }

  /// ✅ Handles adding a new customer with image upload
  void _handleAddCustomer() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (!_validatePhoneNumber(phone)) return; // ✅ Stop if phone is invalid

    setState(() => _isUploading = true);

    // Default Image URL
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/valgrow-new.firebasestorage.app/o/uploaded_images%2Fdefault.jpg?alt=media";

    try {
      if (_selectedImage != null) {
        String imageName = "customer-${DateTime.now().millisecondsSinceEpoch}";
        String? uploadedUrl =
            await Provider.of<StorageService>(context, listen: false)
                .uploadImage(_selectedImage!, imageName, context);
        imageUrl = uploadedUrl ?? imageUrl;
      }

      bool success = await Provider.of<DatabaseProvider>(context, listen: false)
          .addNewCustomer(name: name, phone: phone, imageUrl: imageUrl);

      if (!success) {
        Fluttertoast.showToast(
          msg: "Customer already exists.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      _fetchCustomers();
      final newCustomer = Provider.of<DatabaseProvider>(context, listen: false)
          .customers
          .firstWhereOrNull((c) => c.name == name);

      if (newCustomer != null) {
        widget.onItemSelected(newCustomer);
      }

      Fluttertoast.showToast(
        msg: "Customer successfully added.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding customer. Try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ Header with Close Button
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select or Add a Customer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.black.withOpacity(0.7),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          /// ✅ Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: MySearchbar(
              controller: _searchController,
              onChanged: _filterCustomers, // ✅ Calls filtering function
            ),
          ),

          /// ✅ Customer List (Filtered with Consumer)
          Expanded(
            child: Consumer<DatabaseProvider>(
              builder: (context, databaseProvider, child) {
                final customers =
                    databaseProvider.customers; // ✅ Listen for updates
                final filteredCustomers = _searchController.text.isEmpty
                    ? customers
                    : customers
                        .where((customer) => customer.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .toList();

                return filteredCustomers.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),

                              // ✅ Profile Picture with Border & Placeholder
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFFF6F6F6),
                                      width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: const Color(0xFFF6F6F6),
                                  backgroundImage: customer.imageUrl.isNotEmpty
                                      ? NetworkImage(customer.imageUrl)
                                      : null,
                                  child: customer.imageUrl.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.black.withOpacity(0.5),
                                          size: 20,
                                        )
                                      : null,
                                ),
                              ),

                              // ✅ Name & Phone Number (Stylized)
                              title: Text(
                                customer.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              subtitle: Text(
                                customer.phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),

                              // ✅ Selection Indicator
                              trailing: customer == widget.selectedCustomer
                                  ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF14AE5C),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  : Icon(
                                      Icons.chevron_right,
                                      color: Colors.black.withOpacity(0.3),
                                      size: 20,
                                    ),

                              // ✅ Select Customer
                              onTap: () {
                                widget.onItemSelected(customer);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            "No customers found.",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                // ✅ Empty state
              },
            ),
          ),

          /// ✅ Button to open the alert dialog
          Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () => _showCustomerDetailsDialog(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF14AE5C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Add Customer Details",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
