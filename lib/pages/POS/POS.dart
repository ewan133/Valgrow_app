import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/POS_components/table_pos.dart';
import 'package:valgrow_ui/pages/POS/items_modal.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/models/item_details.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  GlobalKey myAddButton = GlobalKey();
  GlobalKey myScanButton = GlobalKey();
  GlobalKey myCartSummary = GlobalKey();
  GlobalKey myClearButton = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];

  bool isScanning = false;

  void initState() {
    super.initState();
    _checkAndStartTutorial();
  }

  nowStart(_) {
    Future.delayed(Duration(seconds: 0));
    tutorialCoachMark = TutorialCoachMark(targets: myTargets)
      ..show(context: context);
  }

  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownTutorial = prefs.getBool('hasShownPOSTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your targets
      addMyTargets(myAddButton, "myAddButton", ContentAlign.bottom,
          "Add a new product or item to the cart.");
      addMyTargets(myScanButton, "myScanButton", ContentAlign.bottom,
          "Scan an item’s barcode to quickly add it to the cart.");
      addMyTargets(myCartSummary, "myCartSummary", ContentAlign.top,
          "View the summary of all items in the cart, total and the proceed button to proceed into next step.");
      addMyTargets(myClearButton, "myClearButton", ContentAlign.bottom,
          "Clear all items from the current cart.");

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownPOSTutorial', true);
        });
      });
    }
   
  }

  addMyTargets(GlobalKey target, String identifier, ContentAlign alignment,
      String content) {
    myTargets.add(TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      keyTarget: target,
      identify: identifier,
      contents: [
        TargetContent(
          align: alignment,
          padding: EdgeInsets.only(top: 10, bottom: 0, left: 20, right: 20),
          builder: (context, controller) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text("Next", style: TextStyle(fontSize: 14),),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    ));
  }

  // ✅ Method to scan barcode using MobileScanner
  void scanBarcode(BuildContext context) {
    if (isScanning) return;
    isScanning = true;

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
              if (barcodes.isEmpty || !isScanning) return;

              final String scannedCode = barcodes.first.rawValue ?? '';
              if (scannedCode.isEmpty) return;

              // ✅ Prevent multiple detections from triggering too fast
              isScanning = false;

              // ✅ Process scanned barcode
              _processScannedBarcode(context, scannedCode);

              // ✅ Re-enable scanning after a short delay (prevents duplicate scans)
              Future.delayed(const Duration(seconds: 2), () {
                isScanning = true; // ✅ Allow next scan
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              isScanning = false; // ✅ Stop scanning
              Navigator.pop(dialogContext); // ✅ Close scanner manually
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  // ✅ Process scanned barcode
  void _processScannedBarcode(BuildContext context, String barcodeScanResult) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    // ✅ Search for item in the database using barcode
    final scannedItem = databaseProvider.items.firstWhere(
      (item) => item.barcode == barcodeScanResult,
      orElse: () => ItemDetails(
        itemId: '',
        item_name: '',
        regular_price: 0,
        unpaid_price: 0,
        category: '',
        unit: '',
        barcode: '',
        item_image: '',
        storeId: '',
        total_stock: 0,
        last_updated: DateTime.now(),
      ),
    );

    if (scannedItem.itemId.isEmpty) {
      Fluttertoast.showToast(
        msg: "Item not found!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // ✅ Get current quantity in basket
    final currentQuantity = databaseProvider.basket
        .where((i) => i.barcode == scannedItem.barcode)
        .fold(0, (sum, i) => sum + i.total_stock);

    // ✅ Check if adding exceeds available stock
    if (currentQuantity + 1 > scannedItem.total_stock) {
      Fluttertoast.showToast(
        msg: "Stock limit reached for ${scannedItem.item_name}!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // ✅ Create a new item with quantity 1 for POS
    final newItem = ItemDetails(
      itemId: scannedItem.itemId,
      item_name: scannedItem.item_name,
      regular_price: scannedItem.regular_price,
      unpaid_price: scannedItem.unpaid_price,
      category: scannedItem.category,
      unit: scannedItem.unit,
      barcode: scannedItem.barcode,
      item_image: scannedItem.item_image,
      storeId: scannedItem.storeId,
      total_stock: 1, // ✅ Set quantity to 1
      last_updated: scannedItem.last_updated,
    );

    // ✅ Add scanned item to basket
    databaseProvider.addToBasket(newItem);

    // ✅ Show success notification using Fluttertoast
    Fluttertoast.showToast(
      msg: "${newItem.item_name} added to basket!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6), // Match dashboard background
      appBar: MyAppbar(
        title: "Point of Sale",
        actionWidget: TextButton(
          key: myClearButton,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    "Clear Basket",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  content: Text(
                    "Are you sure you want to clear the basket?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<DatabaseProvider>(context, listen: false)
                            .clearBasket();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14AE5C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: const Text(
            "Clear",
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Match dashboard padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Point of Sale",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Scan or add items to create transactions",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons Section
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton.icon(
                              key: myAddButton,
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) => const ItemsModal(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14AE5C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(Icons.add, size: 18),
                              label: Text(
                                "Add Item",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton.icon(
                              key: myScanButton,
                              onPressed: () => scanBarcode(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF38B6FF),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(Icons.qr_code_scanner, size: 18),
                              label: Text(
                                "Scan Item",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Cart Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Shopping Cart",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              databaseProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF14AE5C)))
                  : MyTable(
                      key: myCartSummary,
                      products: databaseProvider.basket
                          .map((item) => {
                                "Product": item.item_name,
                                "Price": item.regular_price,
                                "Quantity": item.total_stock,
                              })
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
