import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditCustomerModal extends StatefulWidget {
  final CustomerDetails customer;

  const EditCustomerModal({super.key, required this.customer});

  @override
  State<EditCustomerModal> createState() => _EditCustomerModalState();
}

class _EditCustomerModalState extends State<EditCustomerModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _selectedImage;
  String? _phoneError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.customer.name;
    _phoneController.text = widget.customer.phone;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

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

  bool _validatePhoneNumber(String phone) {
    setState(() {
      if (phone.isEmpty) {
        _phoneError = "Phone number is required";
      } else if (!RegExp(r'^09\d{9}$').hasMatch(phone)) {
        _phoneError = "Phone number must be 11 digits and start with 09";
      } else {
        _phoneError = null;
      }
    });
    return _phoneError == null;
  }

  Future<void> _handleUpdateCustomer() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty || !_validatePhoneNumber(phone)) return;

    setState(() => _isSaving = true);

    String imageUrl = widget.customer.imageUrl;
    try {
      if (_selectedImage != null) {
        String imageName = "customer-${DateTime.now().millisecondsSinceEpoch}";
        String? uploadedUrl = await Provider.of<StorageService>(context, listen: false)
            .uploadImage(_selectedImage!, imageName, context);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      await Provider.of<DatabaseProvider>(context, listen: false).updateCustomerDetails(
        customerId: widget.customer.customerId,
        name: name,
        phone: phone,
        imageUrl: imageUrl,
      );

      Fluttertoast.showToast(
        msg: "Customer details updated successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to update customer.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Edit Customer",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _showImagePickerOptions,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : NetworkImage(widget.customer.imageUrl) as ImageProvider,
                  child: _selectedImage == null && widget.customer.imageUrl.isEmpty
                      ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Customer Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  errorText: _phoneError,
                ),
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
                    onPressed: _handleUpdateCustomer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Update",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
