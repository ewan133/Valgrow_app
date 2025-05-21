import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/FBA_multi.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/models/batch_details.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/pages/inventory/add_batch_modal.dart';
import 'package:valgrow_ui/pages/inventory/edit_item.dart';
import 'package:valgrow_ui/pages/inventory/reduce_stocks.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ItemDetailsPage extends StatefulWidget {
  final ItemDetails item;
  const ItemDetailsPage({super.key, required this.item});

  @override
  State<ItemDetailsPage> createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  @override
  void initState() {
    super.initState();

    /// 🔹 Fetch batch data AFTER the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchBatchByItemId(widget.item.itemId);
    });
  }

  /// 🔹 Generate a unique batch name
  String generateBatchName() {
    return "${widget.item.item_name}_Batch_${DateFormat('yyyyMMdd-HHmmss').format(DateTime.now())}";
  }

  /// 🔹 Show Confirmation Dialog Before Adding Batch
  void _showConfirmationDialog(
      double purchasePrice, int quantity, DateTime? expirationDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Add Batch"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Batch Name: ${generateBatchName()}"),
            Text("Quantity: $quantity"),
            Text("Purchase Price: ₱${purchasePrice.toStringAsFixed(2)}"),
            // Text(
            //   expirationDate != null
            //       ? "Expiration: ${DateFormat('yyyy-MM-dd').format(expirationDate)}"
            //       : "No Expiration Date",
            // ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ❌ Cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // ✅ Close dialog
              _addBatch(purchasePrice, quantity, expirationDate);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  /// 🔹 Add Batch to Database
  Future<void> _addBatch(
      double purchasePrice, int quantity, DateTime? expirationDate) async {
    // ✅ Create new batch
    ItemBatch newBatch = ItemBatch(
      batchId: '',
      batchName: generateBatchName(), // ✅ Automated batch name
      itemId: widget.item.itemId,
      quantity: quantity,
      purchasePrice: purchasePrice, // ✅ Ensure purchasePrice is valid
      expirationDate: expirationDate,
      storeId: widget.item.storeId,
      createdAt: DateTime.now(),
    );

    // ✅ Add to database
    final databaseProvider = context.read<DatabaseProvider>();
    await databaseProvider.addNewBatch(newBatch);
    await databaseProvider.fetchBatchByItemId(widget.item.itemId);

    print(
        "✅ Added Batch: ${newBatch.batchName}, Quantity: $quantity, Expiration: $expirationDate");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Item Details",
        actionWidget: TextButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => EditItemModal(item: widget.item),
            );
          },
          child: MyText(
            text: "Edit",
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButton: MyFloatingActionButtonMulti(
        text: "Manage Stocks",
        choices: [
          {
            "label": "Add Stocks (by batch)",
            "icon": Icons.layers, // ✅ Choice Icon
            "action": () {
              showDialog(
                context: context,
                builder: (context) {
                  return AddBatchModal(
                    onAddBatch: (purchasePrice, quantity, expirationDate) {
                      // ✅ Ensure the function is executed AFTER closing AddBatchModal
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (mounted) {
                          _showConfirmationDialog(
                              purchasePrice, quantity, expirationDate);
                        }
                      });
                    },
                  );
                },
              );
            },
          },
          {
            "label": "Update Stock",
            "icon": Icons.add_shopping_cart, // ✅ Choice Icon
            "action": () {
              showDialog(
                context: context,
                builder: (context) => ReduceStocksModal(
                  currentStock:
                      widget.item.total_stock, // ✅ Pass current stock count
                  onSave: (int quantity, String reason) {
                    // ✅ Call reduceStock method from provider
                    Provider.of<DatabaseProvider>(context, listen: false)
                        .reduceStock(
                      itemId: widget.item.itemId, // ✅ Use item's ID
                      quantity: quantity,
                      reason: reason,
                    );
                  },
                ),
              );
            },
          }
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Item Details Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 3,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
                child: Consumer<DatabaseProvider>(
                  builder: (context, provider, child) {
                    final item = provider.items.firstWhere(
                      (i) => i.itemId == widget.item.itemId,
                      orElse: () => widget.item,
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image code
                        Center(
                          child: Container(
                            width: 200, // ✅ Fixed width
                            height: 200, // ✅ Fixed height
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  15), // ✅ Rounded Corners
                              border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 2), // ✅ Border
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  15), // ✅ Match Border Radius
                              child: item.item_image.isNotEmpty
                                  ? Image.network(
                                      item.item_image,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/placeholder.png',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        _buildDetailRow("Name:", item.item_name),
                        _buildDetailRow("Category:", item.category),
                        _buildDetailRow("Unit:", item.unit),
                        _buildDetailRow("Barcode:", item.barcode),
                        _buildDetailRow(
                          "Regular Price:",
                          "₱${item.regular_price.toStringAsFixed(2)}",
                        ),
                        _buildDetailRow(
                          "Unpaid Price:",
                          "₱${item.unpaid_price.toStringAsFixed(2)}",
                        ),
                        _buildDetailRow("Total Stock:", "${item.total_stock}"),
                        _buildDetailRow(
                          "Last Updated:",
                          DateFormat('yyyy-MM-dd HH:mm')
                              .format(item.last_updated),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Batch List Section
            const MyText(
              text: "Batch List",
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),

            Consumer<DatabaseProvider>(
              builder: (context, provider, child) {
                final batches = provider.batch;

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (batches.isEmpty) {
                  return const Center(child: Text("No batches available"));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = batches[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      child: ListTile(
                        title: Text("Batch Name: ${batch.batchName}"),
                        subtitle: Text(
                          batch.expirationDate != null
                              ? "Expiration: ${DateFormat('yyyy-MM-dd').format(batch.expirationDate!)}"
                              : "NOEXP", // ✅ Show if expirationDate is null
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Qty:",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(batch.quantity.toString(),
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Widget to display each detail row neatly
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // ✅ Light contrast background
        borderRadius: BorderRadius.circular(8), // ✅ Rounded for smooth UI
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // ✅ Aligns multiline text properly
        children: [
          // 🔹 Label (Bold & Emphasized)
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700, // ✅ Bolder for emphasis
                color: Colors.black87, // ✅ Slightly darker for contrast
              ),
            ),
          ),

          // 🔹 Value (Lighter for distinction)
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right, // ✅ Aligns right for a clean layout
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500, // ✅ Medium weight for balance
                color: Colors.black54, // ✅ Lighter for contrast
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
