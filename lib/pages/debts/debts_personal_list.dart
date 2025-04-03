import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/debts/debt_payment.dart';
import 'package:valgrow_ui/components/debts_components/personal_debts_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/pages/debts/report_customer.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DebtsPersonalList extends StatefulWidget {
  final CustomerDetails customerDetails;

  const DebtsPersonalList({Key? key, required this.customerDetails})
      : super(key: key);

  @override
  State<DebtsPersonalList> createState() => _DebtsPersonalListState();
}

class _DebtsPersonalListState extends State<DebtsPersonalList> {
  late CustomerDetails _customerDetails;

  @override
  void initState() {
    super.initState();
    _customerDetails = widget.customerDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      provider.updateSelectedCustomer(_customerDetails);
      provider.fetchDebtsForCustomer(_customerDetails.customerId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DatabaseProvider>(context);
    if (provider.selectedCustomer != null) {
      _customerDetails = provider.selectedCustomer!;
    }
  }

  void showDebtPaymentDialog(BuildContext context, DebtDetails debt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebtPaymentPage(
          debtDetails: debt,
          customerDetails: _customerDetails,
        ),
      ),
    );

    if (result == true) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      provider.fetchDebtsForCustomer(_customerDetails.customerId);
    }
  }

  void handleReportOverdue(BuildContext context) async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final debts = provider.customerDebts;
    final overdueDebt = debts.firstWhere(
      (debt) => debt.status != 'paid' && debt.dueDate.isBefore(DateTime.now()),
      orElse: () => debts.first,
    );

    final storeId = provider.store?.storeId;
    final storeName = provider.store?.name ?? "Unknown Store";
    final storePhone = provider.store?.contact ?? "N/A";
    final userId = provider.user?.uid;

    final reason = '''
📄 Customer Overdue Report

Customer Information:
• Name     : ${widget.customerDetails.name}
• Phone    : ${widget.customerDetails.phone}

Overdue Debt:
• Debt ID     : ${overdueDebt.debtId}
• Balance     : ₱${overdueDebt.balance.toStringAsFixed(2)}
• Due Date    : ${overdueDebt.dueDate.toLocal().toString().split(' ')[0]}

Reported By:
• Store       : $storeName
• Contact     : $storePhone
• Store ID    : $storeId

This report is filed due to unpaid and overdue debts beyond the agreed due date.
''';

    final controller = TextEditingController(text: reason);

    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportCustomerPage(
          controller: controller,
          onConfirm: () {},
        ),
      ),
    );

    if (confirmed == true && storeId != null && userId != null) {
      await provider.fileCustomerReport(
        storeId: storeId,
        customerId: widget.customerDetails.customerId,
        customerName: widget.customerDetails.name,
        reportReason: controller.text.trim(),
        reportedByUserId: userId,
      );

      Fluttertoast.showToast(
        msg: "Report submitted successfully.",
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final debts = provider.customerDebts;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: MyAppbar(
        title: "Debts",
        actionWidget: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              tooltip: "Edit",
              onPressed: () {},
            ),
            if (debts.any((debt) =>
                debt.status != 'paid' && debt.dueDate.isBefore(DateTime.now())))
              IconButton(
                icon: const Icon(Icons.report, color: Colors.red),
                tooltip: "Report Overdue",
                onPressed: () => handleReportOverdue(context),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            buildCustomerHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : debts.isEmpty
                      ? const Center(child: Text("No debts found."))
                      : ListView.builder(
                          itemCount: debts.length,
                          itemBuilder: (context, index) {
                            final sortedDebts = List<DebtDetails>.from(debts)
                              ..sort((a, b) {
                                const order = {
                                  "unpaid": 0,
                                  "partial": 1,
                                  "paid": 2
                                };
                                return order[a.status]!
                                    .compareTo(order[b.status]!);
                              });

                            final debt = sortedDebts[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () =>
                                    showDebtPaymentDialog(context, debt),
                                child: MyPersonalDebtsCard(debtDetails: debt),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomerHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
              image: DecorationImage(
                image: _customerDetails.imageUrl.isNotEmpty
                    ? NetworkImage(_customerDetails.imageUrl)
                    : const AssetImage("assets/images/sample.jpg")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _customerDetails.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _customerDetails.phone,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                const Divider(thickness: 1, color: Colors.black),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Balance:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "₱${_customerDetails.totalDebt.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
