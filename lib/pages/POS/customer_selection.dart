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
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Customer Details",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerOptionsInDialog,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : null,
                            child: localImage == null
                                ? const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 30)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Customer Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorText: _phoneError,
                        ),
                        onChanged: (value) {
                          _validatePhoneNumber(value);
                        },
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: _handleAddCustomer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isUploading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    "Save",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
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
      padding: const EdgeInsets.all(16),
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ✅ Header with Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select or Add a Customer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 5),

          /// ✅ Search Bar
          MySearchbar(
            controller: _searchController,
            onChanged: _filterCustomers, // ✅ Calls filtering function
          ),
          const SizedBox(
            height: 10,
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

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            elevation: 3, // ✅ Adds subtle shadow effect
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // ✅ Soft rounded corners
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),

                              // ✅ Profile Picture with Border & Placeholder
                              leading: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.black,
                                      width: 2), // ✅ Border
                                ),
                                child: CircleAvatar(
                                  radius: 26,
                                  backgroundColor: Colors
                                      .grey.shade300, // Default background
                                  backgroundImage: customer.imageUrl.isNotEmpty
                                      ? NetworkImage(
                                          customer.imageUrl) // ✅ Load image
                                      : null,
                                  child: customer.imageUrl.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.white,
                                          size: 30) // ✅ Placeholder icon
                                      : null,
                                ),
                              ),

                              // ✅ Name & Phone Number (Stylized)
                              title: Text(
                                customer.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text(
                                customer.phone,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),

                              // ✅ Selection Indicator
                              trailing: customer == widget.selectedCustomer
                                  ? const Icon(Icons.check_circle,
                                      color: Colors.green, size: 24)
                                  : const Icon(Icons.chevron_right,
                                      color: Colors.grey, size: 24),

                              // ✅ Select Customer
                              onTap: () {
                                widget.onItemSelected(customer);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          "No customers found.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                // ✅ Empty state
              },
            ),
          ),

          /// ✅ Button to open the alert dialog
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 15),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showCustomerDetailsDialog(context),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Set the button color to blue
                ),
                child: const Text(
                  "Add Customer Details",
                  style: TextStyle(fontSize: 16), // Set text size to 16
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
