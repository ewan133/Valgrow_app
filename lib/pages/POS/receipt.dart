import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReceiptPage extends StatefulWidget {
  final String transactionId;

  const ReceiptPage({super.key, required this.transactionId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchTransactionDetails(widget.transactionId);
    });
  }

  Future<void> _downloadReceipt() async {
    final Uint8List? image = await _screenshotController.capture();

    if (image != null) {
      // build path inside "Pictures/Receipts"
      final picturesDir = Directory("/storage/emulated/0/Pictures/Receipts");

      // create the folder if it doesn’t exist
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      final filePath =
          '${picturesDir.path}/receipt_${widget.transactionId}.png';
      final file = File(filePath);
      await file.writeAsBytes(image);

      Fluttertoast.showToast(
        msg: "✅ Receipt saved in Pictures/Receipts",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final transactionDetails = provider.transactionDetails;
    final isLoading = provider.isLoadingTransaction;
    final store = provider.store;
    final user = provider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF5DB075),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DB075),
        elevation: 0,
        centerTitle: true,
        title: const Text("Receipt",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: _downloadReceipt,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : transactionDetails == null
              ? const Center(
                  child: Text("❌ Transaction not found",
                      style: TextStyle(color: Colors.white)))
              : Screenshot(
                  controller: _screenshotController,
                  child: Container(
                    color: const Color(0xFF5DB075), // Include the background
                    child: _buildReceipt(transactionDetails, store, user),
                  ),
                ),
    );
  }

  /// ✅ **Build Receipt**
  Widget _buildReceipt(
      Map<String, dynamic> transactionDetails, dynamic store, dynamic user) {
    final transaction = transactionDetails["transaction"];
    final items = transactionDetails["items"];
    final customer = transactionDetails["customer"];
    final debt = transactionDetails["debt"];
    final debtPayments = transactionDetails["debt_payments"];

    final storeName = store?.name ?? "Unknown Store";
    final storeAddress = store?.address ?? "No Address Provided";
    final cashierName = user?.name ?? "Unknown Cashier";
    final isDebtPayment = debtPayments != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: Container(
          width: 280, // ✅ Standard thermal receipt width (58mm)
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🏪 Store Header
              Center(
                child: Column(
                  children: [
                    Text(
                      storeName.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: "Courier",
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      storeAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "Courier",
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "*** OFFICIAL RECEIPT ***",
                      style: const TextStyle(
                        fontFamily: "Courier",
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _doubleLine(),

              /// 📅 Transaction Info
              const SizedBox(height: 4),
              _receiptInfoRow("DATE", DateFormat('MM/dd/yyyy').format(DateTime.parse(transaction["created_at"].toDate().toString()))),
              _receiptInfoRow("TIME", DateFormat('hh:mm a').format(DateTime.parse(transaction["created_at"].toDate().toString()))),
              _receiptInfoRow("CASHIER", cashierName.toUpperCase()),
              if (customer != null)
                _receiptInfoRow("CUSTOMER", customer["name"].toString().toUpperCase()),
              _receiptInfoRow("RECEIPT #", widget.transactionId.substring(0, 8).toUpperCase()),
              _receiptInfoRow("TXN TYPE", transaction["payment_method"].toString().toUpperCase()),

              const SizedBox(height: 8),
              _doubleLine(),

              /// 📜 Items Header
              const SizedBox(height: 4),
              Row(
                children: const [
                  SizedBox(
                    width: 30,
                    child: Text("QTY",
                        style: TextStyle(
                            fontFamily: "Courier",
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Text("ITEM",
                        style: TextStyle(
                            fontFamily: "Courier",
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text("AMOUNT",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontFamily: "Courier",
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              _singleLine(),

              /// 🛒 Items
              for (var item in items) ...[
                const SizedBox(height: 2),
                // Item name and total
                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text("${item['quantity']}",
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 10)),
                    ),
                    Expanded(
                      child: Text(
                        item['item_name'].toString().toUpperCase(),
                        style: const TextStyle(
                            fontFamily: "Courier", 
                            fontSize: 10,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text(
                        "₱${(item['quantity'] * item['unit_price']).toStringAsFixed(2)}",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontFamily: "Courier", 
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Unit price line (if quantity > 1)
                if (item['quantity'] > 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "@ ₱${item['unit_price'].toStringAsFixed(2)} each",
                      style: const TextStyle(
                          fontFamily: "Courier", 
                          fontSize: 9,
                          color: Colors.grey),
                    ),
                  ),
              ],

              const SizedBox(height: 8),
              _singleLine(),

              /// 💰 Totals
              const SizedBox(height: 4),
              _receiptTotal("SUBTOTAL",
                  "₱${transaction["total_amount"].toStringAsFixed(2)}", isLarge: false),
              if (transaction["discount"] != null && transaction["discount"] > 0)
                _receiptTotal("DISCOUNT",
                    "-₱${transaction["discount"].toStringAsFixed(2)}", isLarge: false),
              const SizedBox(height: 4),
              _doubleLine(),
              _receiptTotal("TOTAL AMOUNT",
                  "₱${transaction["total_amount"].toStringAsFixed(2)}", isLarge: true),
              const SizedBox(height: 4),
              if (!isDebtPayment) ...[
                _receiptTotal("CASH TENDERED",
                    "₱${transaction["amount_paid"].toStringAsFixed(2)}", isLarge: false),
                _receiptTotal("CHANGE", 
                    "₱${transaction["change"].toStringAsFixed(2)}", isLarge: false),
              ],

              /// 🔥 Debt Section
              if (debt != null) ...[
                const SizedBox(height: 8),
                _doubleLine(),
                const SizedBox(height: 4),
                const Center(
                  child: Text(
                    "*** CREDIT TRANSACTION ***",
                    style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                _receiptTotal(
                    "OUTSTANDING BALANCE", "₱${debt["balance"].toStringAsFixed(2)}", isLarge: false),
                _receiptTotal("DUE DATE",
                    DateFormat('MM/dd/yyyy').format(debt["due_date"].toDate()), isLarge: false),
              ],

              /// 🔥 Debt Payments Section
              if (debtPayments != null) ...[
                const SizedBox(height: 6),
                Center(child: _dashedLine()),
                const Center(
                  child: Text(
                    "DEBT PAYMENTS",
                    style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                for (var payment in debtPayments)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          DateFormat.yMMMd()
                              .format(payment["payment_date"].toDate()),
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 11)),
                      Text("₱${payment["amount_paid"].toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontFamily: "Courier",
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                      Text(payment["payment_method"].toUpperCase(),
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 11)),
                    ],
                  ),
              ],

              const SizedBox(height: 12),
              _doubleLine(),

              /// 🙏 Footer
              const SizedBox(height: 8),
              const Center(
                child: Text("*** THANK YOU ***",
                    style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0)),
              ),
              const SizedBox(height: 2),
              const Center(
                child: Text("PLEASE COME AGAIN",
                    style: TextStyle(
                        fontFamily: "Courier", 
                        fontSize: 10,
                        letterSpacing: 0.5)),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text("This serves as your official receipt",
                    style: TextStyle(
                        fontFamily: "Courier", 
                        fontSize: 8,
                        fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Single Line
Widget _singleLine() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 2),
    child: Center(
      child: Text(
        "---------------------------------------",
        style: TextStyle(fontFamily: "Courier", fontSize: 10),
      ),
    ),
  );
}

/// ✅ Double Line
Widget _doubleLine() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 2),
    child: Center(
      child: Text(
        "=======================================",
        style: TextStyle(fontFamily: "Courier", fontSize: 10, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

/// ✅ Receipt Info Row
Widget _receiptInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  fontFamily: "Courier",
                  fontSize: 9,
                  fontWeight: FontWeight.w500)),
        ),
        const Text(": ", style: TextStyle(fontFamily: "Courier", fontSize: 9)),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontFamily: "Courier",
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

/// ✅ Dashed Line (kept for backward compatibility)
Widget _dashedLine() {
  return const Center(
    child: Text(
      "---------------------------------------",
      style: TextStyle(fontFamily: "Courier", fontSize: 10),
    ),
  );
}

/// ✅ Total Row
Widget _receiptTotal(String label, String value, {bool isLarge = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: "Courier",
                fontSize: isLarge ? 11 : 10,
                fontWeight: isLarge ? FontWeight.bold : FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontFamily: "Courier",
                fontSize: isLarge ? 11 : 10,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
