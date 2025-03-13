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
  @override
  void initState() {
    super.initState();

    // ✅ Fetch debts for this customer when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchDebtsForCustomer(widget.customerDetails.customerId);
    });
  }

  // ✅ Show Debt Payment Dialog with Specific Debt Details
  void showDebtPaymentDialog(BuildContext context, DebtDetails debt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebtPaymentPage(debtDetails: debt, customerDetails: widget.customerDetails,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final customerDebts = provider.customerDebts;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: const MyAppbar(title: "Debts"),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: Column(
          children: [
            // Customer Info Section
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
                        image: widget.customerDetails.imageUrl.isNotEmpty
                            ? NetworkImage(widget.customerDetails.imageUrl)
                            : const AssetImage("assets/images/sample.jpg")
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12), // Space between image and text

                  // Customer Name & Balance
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.customerDetails.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          widget.customerDetails.phone,
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
                              "₱${widget.customerDetails.totalDebt.toStringAsFixed(2)}",
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
                            final debt = customerDebts[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 13.0),
                              child: GestureDetector(
                                onTap: () => showDebtPaymentDialog(
                                    context, debt), // ✅ Pass specific debt
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
