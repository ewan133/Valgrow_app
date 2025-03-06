import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/POS_components/items_modal_card.dart';
import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ItemsModal extends StatefulWidget {
  const ItemsModal({super.key});

  @override
  State<ItemsModal> createState() => _ItemsModalState();
}

class _ItemsModalState extends State<ItemsModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ✅ Function to Show Floating Notification
  void showOverlayNotification(BuildContext context, String message,
      {bool isError = false, VoidCallback? onUndo}) {
    late OverlayEntry overlayEntry;
    final overlay = Overlay.of(context);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Adjust position
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isError ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, spreadRadius: 2),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onUndo != null)
                  TextButton(
                    onPressed: () {
                      if (overlayEntry.mounted) {
                        overlayEntry.remove(); // ✅ Remove notification
                      }
                      onUndo(); // ✅ Call undo function
                    },
                    child: const Text(
                      "UNDO",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    // ✅ Insert overlay
    overlay.insert(overlayEntry);

    // ✅ Automatically remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    // Sort items: in-stock items first, then out-of-stock
    final sortedItems = databaseProvider.items.toList()
      ..sort((a, b) => b.total_stock.compareTo(a.total_stock));

    // Apply search filter (Searches both `item_name` and `barcode`)
    final filteredItems = sortedItems.where((item) {
      final itemName = item.item_name.toLowerCase();
      final barcode = item.barcode?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return itemName.contains(query) || barcode.contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Select Item",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: MySearchbar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // List View of Sorted & Filtered Items
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text("No items found"))
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return MyItemsModalCard(
                        imageUrl: item.item_image ?? '',
                        itemName: item.item_name ?? 'Unknown',
                        category: item.category ?? 'No Category',
                        stock: item.total_stock.toString(),
                        price: item.regular_price.toString(),
                        onAddPressed: () {
                          // ✅ Get current basket quantity for this item
                          final currentQuantity = databaseProvider.basket
                              .where((i) => i.barcode == item.barcode)
                              .fold(0, (sum, i) => sum + i.total_stock);

                          // ✅ Check if adding exceeds stock
                          if (currentQuantity >= item.total_stock) {
                            showOverlayNotification(
                              context,
                              "Cannot add more than available stock!",
                              isError: true,
                            );
                            return;
                          }

                          // ✅ Create a new item with quantity 1
                          final newItem = ItemDetails(
                            itemId: item.itemId,
                            item_name: item.item_name,
                            regular_price: item.regular_price,
                            unpaid_price: item.unpaid_price,
                            category: item.category,
                            unit: item.unit,
                            barcode: item.barcode,
                            item_image: item.item_image,
                            storeId: item.storeId,
                            total_stock: 1, // ✅ Set quantity to 1
                            last_updated: item.last_updated,
                          );

                          databaseProvider
                              .addToBasket(newItem); // ✅ Add item to basket

                          // ✅ Show Floating Notification with UNDO
                          showOverlayNotification(
                            context,
                            "${newItem.item_name} added to basket!",
                            onUndo: () {
                              databaseProvider.removeFromBasket(
                                  newItem.barcode); // ✅ Undo action
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
