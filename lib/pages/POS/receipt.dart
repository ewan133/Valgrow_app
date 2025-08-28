import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

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
      // get the Pictures directory
      final directory = await getExternalStorageDirectory();

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Receipt saved in Pictures/Receipts")),
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
                  child: _buildReceipt(transactionDetails, store, user),
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
          width: 320, // ✅ narrow like receipt
          color: Colors.white,
          padding: const EdgeInsets.all(20),
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
                        fontFamily: "Courier", // ✅ receipt font
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      storeAddress,
                      textAlign: TextAlign.center, // ✅ Center align
                      style: const TextStyle(
                        fontFamily: "Courier",
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Center(child: _dashedLine()),

              /// 📅 Info
              Text("DATE: ${DateFormat.yMMMd().format(DateTime.now())}",
                  style: const TextStyle(fontFamily: "Courier", fontSize: 11)),
              Text("TIME: ${DateFormat.jm().format(DateTime.now())}",
                  style: const TextStyle(fontFamily: "Courier", fontSize: 11)),
              Text("CASHIER: $cashierName",
                  style: const TextStyle(fontFamily: "Courier", fontSize: 11)),
              if (customer != null)
                Text("CUSTOMER: ${customer["name"]}",
                    style:
                        const TextStyle(fontFamily: "Courier", fontSize: 11)),
              Text("REF: ${widget.transactionId}",
                  style: const TextStyle(fontFamily: "Courier", fontSize: 11)),

              const SizedBox(height: 6),
              Center(child: _dashedLine()),

              /// 📜 Table Header
              Row(
                children: const [
                  Expanded(
                    flex: 2,
                    child: Text("QTY",
                        style: TextStyle(
                            fontFamily: "Courier",
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text("DESCRIPTION",
                        style: TextStyle(
                            fontFamily: "Courier",
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("TOTAL",
                          style: TextStyle(
                              fontFamily: "Courier",
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              Center(child: _dashedLine()),

              /// 🛒 Items
              for (var item in items)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text("${item['quantity']}",
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 11)),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(item['item_name'],
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 11)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "₱${(item['quantity'] * item['unit_price']).toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontFamily: "Courier", fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),

              Center(child: _dashedLine()),

              /// 💰 Totals
              _receiptTotal("TOTAL",
                  "₱${transaction["total_amount"].toStringAsFixed(2)}"),
              if (!isDebtPayment) ...[
                _receiptTotal("CASH",
                    "₱${transaction["amount_paid"].toStringAsFixed(2)}"),
                _receiptTotal(
                    "CHANGE", "₱${transaction["change"].toStringAsFixed(2)}"),
              ],

              /// 🔥 Debt Section
              if (debt != null) ...[
                const SizedBox(height: 6),
                Center(child: _dashedLine()),
                const Center(
                  child: Text(
                    "DEBT TRANSACTION",
                    style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                _receiptTotal(
                    "BALANCE", "₱${debt["balance"].toStringAsFixed(2)}"),
                _receiptTotal("DUE",
                    DateFormat.yMMMd().format(debt["due_date"].toDate())),
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

              const SizedBox(height: 6),
              Center(child: _dashedLine()),

              /// 🙏 Footer
              const Center(
                child: Text("THANK YOU!",
                    style: TextStyle(
                        fontFamily: "Courier",
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
              const Center(
                child: Text("PLEASE COME AGAIN",
                    style: TextStyle(fontFamily: "Courier", fontSize: 11)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Dashed Line
Widget _dashedLine() {
  return const Text(
    "----------------------------------------",
    style: TextStyle(fontFamily: "Courier", fontSize: 11),
  );
}

/// ✅ Total Row
Widget _receiptTotal(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: const TextStyle(
              fontFamily: "Courier",
              fontSize: 12,
              fontWeight: FontWeight.bold)),
      Text(value,
          style: const TextStyle(
              fontFamily: "Courier",
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    ],
  );
}
