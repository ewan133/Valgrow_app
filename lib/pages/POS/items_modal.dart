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
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isError ? Colors.red : const Color(0xFF14AE5C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF6F6F6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onUndo != null) ...[
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      if (overlayEntry.mounted) {
                        overlayEntry.remove();
                      }
                      onUndo();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                    child: Text(
                      "UNDO",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // ✅ Insert overlay
    overlay.insert(overlayEntry);

    // ✅ Automatically remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
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
      final barcode = item.barcode.toLowerCase();
      final query = _searchQuery.toLowerCase();

      return itemName.contains(query) || barcode.contains(query);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Item",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Choose items to add to your cart",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.black.withOpacity(0.6),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Search Bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: MySearchbar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Items Count
          if (filteredItems.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                "${filteredItems.length} item${filteredItems.length != 1 ? 's' : ''} available",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],

          // List View of Sorted & Filtered Items
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14AE5C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.search_off,
                            color: const Color(0xFF14AE5C),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No items found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Try adjusting your search",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];

                      return MyItemsModalCard(
                        imageUrl: item.item_image,
                        itemName: item.item_name,
                        category: item.category,
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
