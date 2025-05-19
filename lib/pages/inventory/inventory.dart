import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/FBA.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/inventory_components/main_inventory_card.dart';
import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/pages/inventory/item_details.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "All"; // Default filter category

  @override
  void initState() {
    super.initState();
    // ✅ Fetch inventory items when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchItemsByStoreId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Inventory",
        actionWidget: Consumer<DatabaseProvider>(
          builder: (context, inventoryProvider, child) {
            // ✅ Extract unique categories dynamically
            List<String> categories = [
              "All",
              ...inventoryProvider.items.map((item) => item.category).toSet()
            ];

            return PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              itemBuilder: (context) => categories
                  .map((category) => PopupMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: MyText(
                  text: "Filter",
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: MyFloatingActionButton(
        text: "Add Product",
        onPressed: () => Navigator.pushNamed(context, '/additem'),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, inventoryProvider, child) {
          final isLoading = inventoryProvider.isLoading;
          final items = inventoryProvider.items;

          if (isLoading) {
            return const Center(
                child: CircularProgressIndicator()); // ✅ Show loading
          }

          // ✅ Apply search and category filters
          final filteredItems = items.where((item) {
            final matchesSearch = _searchQuery.isEmpty ||
                item.item_name.toLowerCase().contains(_searchQuery);
            final matchesCategory = _selectedCategory == "All" ||
                item.category == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList()
            ..sort((a, b) {
              // ✅ First: prioritize in-stock items
              if (a.total_stock > 0 && b.total_stock == 0) return -1;
              if (a.total_stock == 0 && b.total_stock > 0) return 1;

              // ✅ Then: sort alphabetically by item_name
              return a.item_name
                  .toLowerCase()
                  .compareTo(b.item_name.toLowerCase());
            });

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: MySearchbar(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? const Center(
                        child: MyText(
                          text: "No items found",
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailsPage(item: item),
                                  ),
                                );
                              },
                              child: MainInventoryCard(item: item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
