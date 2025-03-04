import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/dropdown.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';

class AdditemPage extends StatefulWidget {
  const AdditemPage({super.key});

  @override
  State<AdditemPage> createState() => _AdditemPageState();
}

class _AdditemPageState extends State<AdditemPage> {
  String uid = "";
  File? _image;
  final _inventoryDB = InventoryDatabase();

  bool _isUploading = false;
  bool _isLoading = true;

  final List<String> units = ["Quantity", "Kilogram"];
  List<String> categories = [];

  String? unitValue;
  String? categoryValue;
  final _nameController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _unpaidPriceController = TextEditingController();
  final _barcodeController = TextEditingController();
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);
  UserProfile? user;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      user = provider.user;
      if (user == null) return;

      Set<String> categorySet =
          Set.from(await _inventoryDB.getUniqueCategories(user!.storeId));

      categorySet.addAll(["Canned Foods", "Noodles"]); // Add extra categories

      setState(() {
        categories = [...categorySet.toList()]; // Keep "All" first
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading categories: $e")),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to pick image")),
      );
    }
  }

  void _addItem() async {
    final user = Provider.of<DatabaseProvider>(context, listen: false).user;
    if (_nameController.text.trim().isEmpty ||
        _regularPriceController.text.trim().isEmpty ||
        _unpaidPriceController.text.trim().isEmpty ||
        _barcodeController.text.trim().isEmpty ||
        unitValue == null ||
        categoryValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    String imageName = "${user!.storeId}-${_nameController.text.trim()}";
    String imageUrl =
        "https://firebasestorage.googleapis.com/v0/b/valgrow-new.firebasestorage.app/o/uploaded_images%2Fdefault.jpg?alt=media&token=bdcf0700-ee5d-44ea-b2d3-02263d732fbd";

    try {
      if (_image != null) {
        String? uploadedUrl =
            await Provider.of<StorageService>(context, listen: false)
                .uploadImage(_image!, imageName, context);
        imageUrl = uploadedUrl ?? imageUrl;
      }

      final ItemDetails newItem = ItemDetails(
        itemId: '',
        item_name: _nameController.text.trim(),
        regular_price: double.parse(_regularPriceController.text.trim()),
        unpaid_price: double.parse(_unpaidPriceController.text.trim()),
        category: categoryValue!,
        unit: unitValue!,
        barcode: _barcodeController.text.trim(),
        item_image: imageUrl,
        storeId: user.storeId, // Ensured to be non-null here
        total_stock: 0,
        last_updated: DateTime.now(),
      );

      await databaseProvider.addNewItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item Successfully Saved")),
      );
      // Clear form after success
      _nameController.clear();
      _regularPriceController.clear();
      _unpaidPriceController.clear();
      _barcodeController.clear();
      setState(() {
        _image = null;
        unitValue = null;
        categoryValue = null;
      });
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving item: ${e.toString()}")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Add Item"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 150,
                            height: 150,
                            color: Colors.grey[300],
                            child: _image == null
                                ? const Icon(Icons.image,
                                    size: 50, color: Colors.grey)
                                : Image.file(_image!, fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    MyTextfieldLabeled(
                      color: Colors.grey.shade400,
                      controller: _nameController,
                      label: "Item Name:",
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyTextfieldLabeled(
                      color: Colors.grey.shade400,
                      controller: _regularPriceController,
                      label: "Regular Price:",
                      isNumeric: true,
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyTextfieldLabeled(
                      color: Colors.grey.shade400,
                      controller: _unpaidPriceController,
                      label: "Unpaid Price:",
                      isNumeric: true,
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyDropdown(
                      text: 'Category:',
                      color: Colors.grey.shade400,
                      choices: categories,
                      selectedValue: categoryValue,
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
        
                            if (!categories.contains(newValue)) {
                              categories.add(newValue);
                            }
                            categoryValue = newValue;
                          });
                        }
                      },
                      showAddNew: true,
                    ),
                    const SizedBox(height: 8),
                    MyDropdown(
                      text: "Unit:",
                      color: Colors.grey.shade400,
                      choices: units,
                      selectedValue: unitValue,
                      onChanged: (value) => setState(() => unitValue = value),
                      showAddNew: false,
                    ),
                    const SizedBox(height: 8),
                    MyTextfieldLabeled(
                      color: Colors.grey.shade400,
                      controller: _barcodeController,
                      label: "Barcode:",
                      hint: '',
                    ),
                    const SizedBox(height: 20),
                    _isUploading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF14AE5C))
                        : MyButton(
                            text: "Add Item",
                            color: const Color(0xFF14AE5C),
                            onTap: _addItem,
                            borderRadius: 100,
                            width: double.infinity,
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
