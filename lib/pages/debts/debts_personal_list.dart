import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/debts/debt_payment.dart';
import 'package:valgrow_ui/components/debts_components/personal_debts_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DebtsPersonalList extends StatefulWidget {
  final CustomerDetails customerDetails; // ✅ Required Customer Details

  const DebtsPersonalList({Key? key, required this.customerDetails})
      : super(key: key);

  @override
  State<DebtsPersonalList> createState() => _DebtsPersonalListState();
}

class _DebtsPersonalListState extends State<DebtsPersonalList> {
  late CustomerDetails _customerDetails; // ✅ Mutable variable for updates

  @override
  void initState() {
    super.initState();
    _customerDetails = widget.customerDetails;

    // ✅ Save selected customer in provider
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

  // ✅ Show Debt Payment Dialog with Specific Debt Details
  void showDebtPaymentDialog(BuildContext context, DebtDetails debt) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtPaymentPage(
          debtDetails: debt,
          customerDetails: _customerDetails,
        ),
      ),
    );

    // ✅ If a payment was successful, update debts & UI
    if (result == true) {
      final provider = Provider.of<DatabaseProvider>(context, listen: false);
      provider.fetchDebtsForCustomer(_customerDetails.customerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final customerDebts = provider.customerDebts;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar:  MyAppbar(
        title: "Debts",
        actionWidget: TextButton(onPressed: () => {}, child: Text("edit")),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Column(
          children: [
            // ✅ Updated customer info section (listens for changes)
            Container(
              padding: const EdgeInsets.only(bottom: 15),
              width: double.infinity,
              height: 113,
              child: Row(
                children: [
                  // Profile Image
                  Container(
                    width: 113,
                    height: 113,
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
                  const SizedBox(width: 12),

                  // Customer Name & Balance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _customerDetails.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          _customerDetails.phone,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Divider(color: Colors.black, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Balance:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "₱${_customerDetails.totalDebt.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Debts List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : customerDebts.isEmpty
                      ? const Center(child: Text("No debts found."))
                      : ListView.builder(
                          itemCount: customerDebts.length,
                          itemBuilder: (context, index) {
                            // ✅ Sort debts: unpaid → partial → paid
                            final sortedDebts =
                                List<DebtDetails>.from(customerDebts)
                                  ..sort((a, b) {
                                    const order = {
                                      "unpaid": 0,
                                      "partial": 1,
                                      "paid": 2
                                    };
                                    return order[a.status]
                                            ?.compareTo(order[b.status] ?? 2) ??
                                        0;
                                  });

                            final debt = sortedDebts[index];

                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 3),
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
}
