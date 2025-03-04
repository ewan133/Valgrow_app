import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/dropdown.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';

class EditItemModal extends StatefulWidget {
  final ItemDetails item;

  const EditItemModal({super.key, required this.item});

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  File? _image;
  bool _isUploading = false;
  late String categoryValue;
  late String unitValue;

  final _nameController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _unpaidPriceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _inventoryDB = InventoryDatabase();
  final List<String> units = ["Quantity", "Kilogram"];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  void _loadItemData() {
    _getCategories();
    _nameController.text = widget.item.item_name;
    _regularPriceController.text = widget.item.regular_price.toString();
    _unpaidPriceController.text = widget.item.unpaid_price.toString();
    _barcodeController.text = widget.item.barcode;
    categoryValue = widget.item.category;
    unitValue = widget.item.unit;
  }

  void _getCategories() async {
    try {
      Set<String> categorySet =
          Set.from(await _inventoryDB.getUniqueCategories(widget.item.storeId));
      categorySet.addAll(["Canned Foods", "Noodles"]);
      categories = categorySet.toList();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading categories: $e")),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  void _saveItem() async {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty ||
        _regularPriceController.text.trim().isEmpty ||
        _unpaidPriceController.text.trim().isEmpty ||
        _barcodeController.text.trim().isEmpty ||
        categoryValue.isEmpty ||
        unitValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    String imageUrl = widget.item.item_image;

    if (_image != null) {
      final storageService =
          Provider.of<StorageService>(context, listen: false);
      String? uploadedUrl = await storageService.uploadImage(
        _image!,
        widget.item.itemId,
        context,
      );
      if (uploadedUrl != null) imageUrl = uploadedUrl;
    }

    final ItemDetails updatedItem = ItemDetails(
      item_name: _nameController.text.trim(),
      regular_price: double.parse(_regularPriceController.text.trim()),
      unpaid_price: double.parse(_unpaidPriceController.text.trim()),
      barcode: _barcodeController.text.trim(),
      category: categoryValue,
      unit: unitValue,
      item_image: imageUrl,
      last_updated: DateTime.now(),
      itemId: widget.item.itemId,
      storeId: widget.item.storeId,
      total_stock: widget.item.total_stock,
    );

    await databaseProvider.editItem(updatedItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item Successfully Updated")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GestureDetector(
          onTap: () =>
              FocusScope.of(context).unfocus(), // Dismiss keyboard on tap
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom), // Adjust for keyboard
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior
                    .manual, // Dismiss keyboard on drag
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),

                      /// Image Upload Section
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[300],
                              child: _image == null
                                  ? Image.network(widget.item.item_image,
                                      fit: BoxFit.cover)
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

                      /// Input Fields
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
                        onChanged: (value) =>
                            setState(() => unitValue = value!),
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

                      /// Save Button
                      _isUploading
                          ? const CircularProgressIndicator(
                              color: Color(0xFF14AE5C))
                          : MyButton(
                              text: "Save Changes",
                              color: const Color(0xFF14AE5C),
                              onTap: _saveItem,
                              borderRadius: 100,
                              width: double.infinity,
                            ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
