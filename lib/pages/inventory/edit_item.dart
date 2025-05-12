import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error picking image. Please try again.")),
      );
      print("❌ Error picking image: $e");
    }
  }

  Future<void> _chooseImageSource() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _saveItem() async {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    if (_nameController.text.trim().isEmpty ||
        _regularPriceController.text.trim().isEmpty ||
        _unpaidPriceController.text.trim().isEmpty ||
        categoryValue.isEmpty ||
        unitValue.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    num regularPrice = num.parse(_regularPriceController.text.trim());
    num unpaidPrice = num.parse(_unpaidPriceController.text.trim());
    // Check if the unpaid price is right

    if (unpaidPrice < regularPrice) {
      Fluttertoast.showToast(
        msg:
            "The unpaid price must be greater than or equal the regular price!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
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


    Fluttertoast.showToast(
      msg: "Item Successfully Updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pop(context);
  }

  void scanBarcode(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Scan Barcode"),
        content: SizedBox(
          height: 100,
          width: 300,
          child: MobileScanner(
            onDetect: (BarcodeCapture capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final String scannedCode = barcodes.first.rawValue ?? '';
              if (scannedCode.isEmpty) return;

              // ✅ Update the barcode text field
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext); // ✅ Close scanner after scanning
                _barcodeController.text = scannedCode;
              }
            },
          ),
        ),
      ),
    );
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
                              onTap: () => _chooseImageSource(),
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
                      Row(
                        children: [
                          Expanded(
                            child: MyTextfieldLabeled(
                              color: Colors.grey.shade400,
                              controller: _barcodeController,
                              label: "Barcode:",
                              hint: '',
                            ),
                          ),
                          const SizedBox(
                              width: 8), // Space between text field and button
                          Padding(
                            padding: const EdgeInsets.only(top: 22.0),
                            child: SizedBox(
                              height:
                                  53, // Set the same height as the text field
                              child: ElevatedButton.icon(
                                onPressed: () => scanBarcode(
                                    context), // Function to trigger barcode scan
                                icon: const Icon(Icons.qr_code_scanner,
                                    size: 30, color: Colors.black),
                                label: const Text("Scan"),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        8), // Circular border radius
                                    side: BorderSide(
                                      // Removed 'const' here
                                      color:
                                          Colors.grey.shade400, // Border color
                                      width: 1, // Border width
                                    ),
                                  ),
                                  backgroundColor:
                                      Colors.white, // Adjust button color
                                  foregroundColor:
                                      Colors.black, // Text and icon color
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16), // Better spacing
                                ),
                              ),
                            ),
                          ),
                        ],
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
