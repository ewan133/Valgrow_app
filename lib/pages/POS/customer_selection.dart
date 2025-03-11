import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';

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
      barrierDismissible: false, // ❌ Prevent dismiss without saving
      builder: (context) {
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
                  /// ✅ Header with Close Button
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

                  /// ✅ Image Picker with Camera & Gallery Options
                  Center(
                    child: GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null,
                        child: _selectedImage == null
                            ? const Icon(Icons.camera_alt,
                                color: Colors.white, size: 30)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// ✅ Name Input Field
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

                  /// ✅ Phone Input Field
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  /// ✅ Actions (Cancel & Save Buttons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: _handleAddCustomer, // ✅ Calls add customer
                        child: _isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Save"),
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
  }

  /// ✅ Handles adding a new customer with image upload
  void _handleAddCustomer() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Default Image URL
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/valgrow-new.firebasestorage.app/o/uploaded_images%2Fdefault.jpg?alt=media";

    try {
      // ✅ Upload image if selected
      if (_selectedImage != null) {
        String imageName = "customer-${DateTime.now().millisecondsSinceEpoch}";
        String? uploadedUrl =
            await Provider.of<StorageService>(context, listen: false)
                .uploadImage(_selectedImage!, imageName, context);
        imageUrl = uploadedUrl ?? imageUrl;
      }

      bool success = await Provider.of<DatabaseProvider>(context, listen: false)
          .addNewCustomer(name: name, phone: phone, imageUrl: imageUrl);

      if (success) {
        print("🎉 Customer added successfully!");
        _fetchCustomers(); // ✅ Refresh customer list

        /// ✅ Automatically select the new customer
        final newCustomer =
            Provider.of<DatabaseProvider>(context, listen: false)
                .customers
                .firstWhere((c) => c.name == name);

        widget.onItemSelected(newCustomer);
        Navigator.pop(context); // ✅ Close the modal
      } else {
        print("⚠️ Customer already exists.");
      }
    } catch (e) {
      print("❌ Error adding customer: $e");
    } finally {
      setState(() => _isUploading = false);
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
          const SizedBox(height: 15),

          /// ✅ Search Bar
          MySearchbar(
            controller: _searchController,
            onChanged: _filterCustomers, // ✅ Calls filtering function
          ),
          const SizedBox(height: 10),

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

                          return ListTile(
                            title: Text(customer.name),
                            subtitle: Text(customer.phone),
                            trailing: customer == widget.selectedCustomer
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            onTap: () {
                              widget.onItemSelected(customer);
                              Navigator.pop(context);
                            },
                          );
                        },
                      )
                    : const Center(
                        child: Text("No customers found."),
                      ); // ✅ Empty state
              },
            ),
          ),

          /// ✅ Button to open the alert dialog
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showCustomerDetailsDialog(context),
              child: const Text("Add Customer Details"),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
