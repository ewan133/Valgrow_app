import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/POS_components/table_pos.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/pages/POS/items_modal.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: MyAppbar(
        title: "Point of Sale",
        actionWidget: TextButton(
          onPressed: () {
            // ✅ Use a function block, not an object
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
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => ItemsModal(),
                      );
                    },
                    borderRadius: 8,
                    width: 110,
                  ),
                  const SizedBox(width: 20),
                  MyButton(
                    text: "Scan",
                    color: const Color(0xFF38B6FF),
                    onTap: () {},
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
