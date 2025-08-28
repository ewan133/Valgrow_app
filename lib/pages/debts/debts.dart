import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/components/debts_components/debt_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/searchbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/pages/debts/debts_personal_list.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/components/global_keys.dart';
import 'package:valgrow_ui/components/target.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch debts when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchDebtsWithCustomerInfo();
    });
    _checkAndStartTutorial();
    
  }

  //Needed Intances
  
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];
  Target target = Target();

  //Needed method
  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear(); /// tanggalin mamaya
    final hasShownTutorial =
        prefs.getBool('hasShownMainDebtsTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your targets
      target.addMyTargets(
          mainDebtsSearch,
          "mainDebtsSearch",
          ContentAlign.bottom,
          "You can use this search button to find specific person debts list.",
          myTargets);

      target.addMyTargets(
          mainDebtsList,
          "mainDebtsList",
          ContentAlign.bottom,
          "This part will display all the person with debts and your search results",
          myTargets);

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownMainDebtsTutorial', true);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final customersWithDebts =
        provider.debtsWithCustomers; // ✅ Grouped by customer
    final isLoading = provider.isLoading;
    final searchQuery = _searchController.text.toLowerCase();

    // ✅ Filter customers based on search query (by customer name)
    final filteredCustomers = customersWithDebts.where((entry) {
      CustomerDetails? customer = entry["customer"];
      return customer != null &&
          customer.name.toLowerCase().contains(searchQuery);
    }).toList();

    // ✅ Sort by nearest due date (earliest first)
    filteredCustomers.sort((a, b) {
      DateTime? dueDateA = a["nearestDueDate"];
      DateTime? dueDateB = b["nearestDueDate"];

      if (dueDateA == null && dueDateB == null) return 0; // Keep order
      if (dueDateA == null) return 1; // Move nulls to the end
      if (dueDateB == null) return -1; // Move nulls to the end
      return dueDateA.compareTo(dueDateB); // Sort ascending (earliest first)
    });

    return Scaffold(
      appBar: MyAppbar(title: "Debts"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: MySearchbar(
              key: mainDebtsSearch,
              controller: _searchController,
              onChanged: (value) => setState(() {}), // Refresh list on search
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCustomers.isEmpty
                    ? const Center(child: Text("No debts found."))
                    : ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final debtEntry = filteredCustomers[index];
                          final CustomerDetails? customer =
                              debtEntry["customer"] as CustomerDetails?;
                          final double totalBalance =
                              debtEntry["totalBalance"] ?? 0.0;
                          final DateTime? nearestDueDate =
                              debtEntry["nearestDueDate"];

                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10.0, left: 10, right: 10),
                            child: GestureDetector(
                              onTap: () async {
                                final provider = Provider.of<DatabaseProvider>(
                                    context,
                                    listen: false);
                                provider.updateSelectedCustomer(customer!);
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DebtsPersonalList(
                                        customerDetails: customer),
                                  ),
                                );

                                // ✅ Only update debts if payment was made
                                if (result == true && mounted) {
                                  Future.delayed(Duration.zero, () {
                                    if (mounted) {
                                      Provider.of<DatabaseProvider>(context,
                                              listen: false)
                                          .fetchDebtsWithCustomerInfo();
                                    }
                                  });
                                }
                              },
                              child: MyDebtsCard(
                                customerDetails:
                                    customer, // ✅ Pass customer info
                                totalBalance:
                                    totalBalance, // ✅ Pass total debt balance
                                nearestDueDate:
                                    nearestDueDate, // ✅ Pass nearest due date
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
