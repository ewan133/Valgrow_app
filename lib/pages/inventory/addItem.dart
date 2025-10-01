import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/dropdown.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';
import 'package:valgrow_ui/components/global_keys.dart';
import 'package:valgrow_ui/components/target.dart';

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

    //_checkAndStartTutorial();
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
      Fluttertoast.showToast(
        msg: "Error loading categories: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> _chooseImageSource() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.black),
              title: Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.black),
              title: Text("Choose from Gallery"),
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to pick image",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _addItem() async {
    final user = Provider.of<DatabaseProvider>(context, listen: false).user;
    final items = Provider.of<DatabaseProvider>(context, listen: false).items;

    if (_nameController.text.trim().isEmpty ||
        _regularPriceController.text.trim().isEmpty ||
        _unpaidPriceController.text.trim().isEmpty ||
        unitValue == null ||
        categoryValue == null) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    String barcode = _barcodeController.text.trim();
    num regularPrice = num.parse(_regularPriceController.text.trim());
    num unpaidPrice = num.parse(_unpaidPriceController.text.trim());

    // Check if a barcode is entered and ensure it's unique
    if (barcode.isNotEmpty && items.any((item) => item.barcode == barcode)) {
      Fluttertoast.showToast(
        msg: "An item with this barcode already exists!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

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
        barcode: barcode, // Can be empty but must be unique if filled
        item_image: imageUrl,
        storeId: user.storeId,
        total_stock: 0,
        last_updated: DateTime.now(),
      );

      await Provider.of<DatabaseProvider>(context, listen: false)
          .addNewItem(newItem);

      Fluttertoast.showToast(
        msg: "Item Successfully Saved",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
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
      Fluttertoast.showToast(
        msg: "Error saving item: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

//Needed Intances
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];
  Target target = Target();

  //Needed method
  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    myTargets.clear();
    final hasShownTutorial =
        prefs.getBool('hasShownAddProductTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your targets
      target.addMyTargets(
          addItemImage,
          "addItemImage",
          ContentAlign.bottom,
          "Tap here to upload or capture a photo of the product for easy identification.",
          myTargets);

      target.addMyTargets(
          addItemName,
          "addItemName",
          ContentAlign.bottom,
          "Enter the product’s name here. This will appear in the inventory and sales records.",
          myTargets);

      target.addMyTargets(
          addItemRegularPrice,
          "addItemRegularPrice",
          ContentAlign.top,
          "Set the regular selling price for customers paying in full.",
          myTargets);

      target.addMyTargets(
          addItemUnpaidPrice,
          "addItemUnpaidPrice",
          ContentAlign.top,
          "Set the selling price for customers paying later (unpaid or credit transactions).",
          myTargets);

      target.addMyTargets(
          addItemCategory,
          "addItemCategory",
          ContentAlign.top,
          "Choose the category for this product to help organize your inventory.",
          myTargets);

      target.addMyTargets(
          addItemUnit,
          "addItemUnit",
          ContentAlign.top,
          "Specify the unit of measurement for this product, such as pcs, kg, or box.",
          myTargets);

      target.addMyTargets(
          addItemBarcode,
          "addItemBarcode",
          ContentAlign.top,
          "Scan or enter the product’s barcode to speed up searches and sales.",
          myTargets);

      target.addMyTargets(
          addItemSaveButton,
          "addItemSaveButton",
          ContentAlign.top,
          "Click here to save the new product to your inventory.",
          myTargets);

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownAddProductTutorial', false);
        });
      });
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
                          key: addItemImage,
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
                    MyTextfieldLabeled(
                      key: addItemName,
                      color: Colors.grey.shade400,
                      controller: _nameController,
                      label: "Item Name:",
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyTextfieldLabeled(
                      key: addItemRegularPrice,
                      color: Colors.grey.shade400,
                      controller: _regularPriceController,
                      label: "Regular Price:",
                      isNumeric: true,
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyTextfieldLabeled(
                      key: addItemUnpaidPrice,
                      color: Colors.grey.shade400,
                      controller: _unpaidPriceController,
                      label: "Unpaid Price:",
                      isNumeric: true,
                      hint: '',
                    ),
                    const SizedBox(height: 8),
                    MyDropdown(
                      key: addItemCategory,
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
                      key: addItemUnit,
                      text: "Unit:",
                      color: Colors.grey.shade400,
                      choices: units,
                      selectedValue: unitValue,
                      onChanged: (value) => setState(() => unitValue = value),
                      showAddNew: false,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      key: addItemBarcode,
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
                            height: 53, // Set the same height as the text field
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
                                    color: Colors.grey.shade400, // Border color
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
                    _isUploading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF14AE5C))
                        : MyButton(
                            key: addItemSaveButton,
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
