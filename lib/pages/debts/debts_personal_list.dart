import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/components/global_keys.dart';
import 'package:valgrow_ui/components/target.dart';
import 'package:valgrow_ui/pages/debts/debt_payment.dart';
import 'package:valgrow_ui/components/debts_components/personal_debts_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/pages/debts/edit_customer.dart';
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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _customerDetails = widget.customerDetails;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      provider.updateSelectedCustomer(_customerDetails);
      provider.fetchDebtsForCustomer(_customerDetails.customerId);
    });

    // _checkAndStartTutorial();
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
📄 Customer Default Report

This report is filed by "$storeName" against a customer with overdue debt obligations.

Business Information:
• Store Name : $storeName
• Store ID : $storeId
• Contact : $storePhone

Customer Information:
• Name : ${widget.customerDetails.name}
• Contact : ${widget.customerDetails.phone}
• Customer ID : ${widget.customerDetails.customerId}

Report Details:
• Report Type : Debt Dispute
• Debt ID : ${overdueDebt.debtId}
• Outstanding Balance : ₱${overdueDebt.balance.toStringAsFixed(2)}
• Original Due Date : ${overdueDebt.dueDate.toLocal().toString().split(' ')[0]}
• Days Overdue : ${DateTime.now().difference(overdueDebt.dueDate).inDays} days

Reason for Report:
This customer has failed to meet their debt obligations despite the agreed-upon due date. The outstanding amount remains unpaid beyond the contractual terms, resulting in this formal report for debt collection or dispute resolution purposes.
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
      final result = await provider.fileCustomerReport(
        storeId: storeId,
        customerId: widget.customerDetails.customerId,
        customerName: widget.customerDetails.name,
        reportReason: controller.text.trim(),
        reportedByUserId: userId,
        reportedBalance: overdueDebt.balance,
      );

      if (result == 'SUCCESS') {
        Fluttertoast.showToast(
          msg: "Report submitted successfully.",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else if (result == 'DUPLICATE_BY_USER') {
        Fluttertoast.showToast(
          msg: "You have already reported this customer for this balance amount (₱${overdueDebt.balance.toStringAsFixed(2)}).",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else if (result?.startsWith('DUPLICATE_BY_COLLEAGUE|') == true) {
        final reporterName = result!.split('|')[1];
        Fluttertoast.showToast(
          msg: "$reporterName has already reported this customer for this balance amount (₱${overdueDebt.balance.toStringAsFixed(2)}).",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to submit report. Please try again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future<void> _editCustomer() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);

      // ✅ Use the current selected customer from the provider
      final currentCustomer = provider.selectedCustomer;

      if (currentCustomer == null) {
        throw Exception("No customer selected.");
      }

      final updatedCustomer = await showDialog<CustomerDetails>(
        context: context,
        builder: (context) => EditCustomerModal(
          customer: currentCustomer,
        ),
      );

      if (updatedCustomer != null) {
        // ✅ Update the customer in database and get the updated version
        CustomerDetails? refreshedCustomer =
            await provider.updateCustomerDetails(
          customerId: updatedCustomer.customerId,
          name: updatedCustomer.name,
          phone: updatedCustomer.phone,
          imageUrl: updatedCustomer.imageUrl,
        );

        if (refreshedCustomer != null) {
          provider.updateSelectedCustomer(refreshedCustomer);
          await provider.fetchDebtsForCustomer(refreshedCustomer.customerId);
          await provider.fetchCustomersByStoreId();
        }

        Fluttertoast.showToast(
          msg: "Customer details updated successfully",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        print("✅ Customer updated successfully: ${refreshedCustomer?.name}");
      }
    } catch (e) {
      print("❌ Error updating customer: $e");
      Fluttertoast.showToast(
        msg: "Failed to update customer details",
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

//Needed Intances
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];
  Target target = Target();

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
              key: DebtsPersonalEdit,
              icon: _isUpdating
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : const Icon(Icons.edit, color: Colors.black),
              tooltip: "Edit",
              onPressed: _isUpdating ? null : _editCustomer,
            ),
            if (debts.any((debt) =>
                debt.status != 'paid' && debt.dueDate.isBefore(DateTime.now())))
              IconButton(
                key: DebtsPersonalReport,
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
              key: DebtsPersonalListKey,
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
    final customer = Provider.of<DatabaseProvider>(context).selectedCustomer;

    if (customer == null) {
      return const SizedBox.shrink();
    }

    return Container(
      key: DebtsPersonalDetails,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
                image: customer.imageUrl.isNotEmpty
                    ? NetworkImage(customer.imageUrl)
                    : const AssetImage("assets/images/sample.jpg")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  customer.phone,
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
                        "₱${customer.totalDebt.toStringAsFixed(2)}",
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
