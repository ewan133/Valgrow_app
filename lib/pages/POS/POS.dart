import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/POS_components/table_pos.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/pages/POS/items_modal.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/models/item_details.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  // ✅ Method to scan barcode
  Future<void> scanBarcode() async {
    bool keepScanning = true;

    while (keepScanning) {
      String barcodeScanResult;
      try {
        barcodeScanResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", // Scanner color
          "Cancel", // Cancel button text
          true, // Show flash icon
          ScanMode.BARCODE, // Scan only barcodes
        );

        if (barcodeScanResult == "-1") {
          // ✅ User canceled scan → Exit loop
          keepScanning = false;
          break;
        }

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
          continue; // ✅ Continue scanning next item
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
          continue; // ✅ Continue scanning next item
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

        // ✅ Small delay to prevent accidental rapid scanning
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Scan failed: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        keepScanning = false; // ✅ Stop scanning if an error occurs
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      appBar: MyAppbar(
        title: "Point of Sale",
        actionWidget: TextButton(
          onPressed: () {
            Provider.of<DatabaseProvider>(context, listen: false).clearBasket();
          },
          child: const Text(
            "Clear",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyButton(
                    text: "Add",
                    color: const Color(0xFF14AE5C),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => const ItemsModal(),
                      );
                    },
                    borderRadius: 8,
                    width: 110,
                  ),
                  const SizedBox(width: 20),
                  MyButton(
                    text: "Scan",
                    color: const Color(0xFF38B6FF),
                    onTap: scanBarcode, // ✅ Call scan function
                    borderRadius: 8,
                    width: 110,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              MyText(
                text: "POS Product Item",
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 10),
              databaseProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyTable(
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
