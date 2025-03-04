import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/POS_components/table_pos.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class POSPage extends StatefulWidget {
  const POSPage({super.key});

  @override
  State<POSPage> createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  final List<Map<String, dynamic>> products = [
    {"Product": "Laptop", "Price": 1000, "Quantity": 1},
    {"Product": "Smartphone", "Price": 700, "Quantity": 2},
    {"Product": "Tablet", "Price": 500, "Quantity": 3},
    {"Product": "Monitor", "Price": 300, "Quantity": 1},
    {"Product": "Keyboard", "Price": 50, "Quantity": 4},
    {"Product": "Laptop", "Price": 1000, "Quantity": 1},
    {"Product": "Smartphone", "Price": 700, "Quantity": 2},
    {"Product": "Tablet", "Price": 500, "Quantity": 3},
    {"Product": "Monitor", "Price": 300, "Quantity": 1},
    {"Product": "Keyboard", "Price": 50, "Quantity": 4},
  ];

  /// Calculate total cost dynamically
  double calculateTotal() {
    return products.fold(
        0,
        (sum, product) =>
            sum + (product["Price"] as num) * (product["Quantity"] as num));
  }

  /// Calculate total items dynamically
  double calculateTotalItems() {
    return products.fold(
        0, (sum, product) => sum + (product["Quantity"] as num));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(
        title: "Point of Sale",
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
                    onTap: () {},
                    borderRadius: 8,
                    width: 110,
                  ),
                  const SizedBox(width: 20), // Add spacing between buttons
                  MyButton(
                    text: "Scan",
                    color: const Color(0xFF38B6FF),
                    onTap: () {},
                    borderRadius: 8,
                    width: 110,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              MyText(
                  text: "POS Product Item",
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
              SizedBox(
                height: 10,
              ),
        
              MyTable(products: products),
        
              /// Complete Transaction Button
              MyButton(
                text: "Complete Transaction",
                color: const Color(0xFF14AE5C),
                width: double.infinity,
                borderRadius: 100,
                onTap: () {},
              )
            ],
          ),
        ),
      ),
    );
  }
}
