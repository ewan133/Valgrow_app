import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/debts_components/debt_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/searchbar.dart';

class DebtsPage extends StatefulWidget {
  const DebtsPage({super.key});

  @override
  State<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends State<DebtsPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Debts"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 10.0, bottom: 10, right: 15, left: 15),
            child: MySearchbar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 10.0, left: 10, right: 10),
                    child: GestureDetector(
                        onTap: () =>
                            {Navigator.pushNamed(context, '/personallist')},
                        child: MyDebtsCard()),
                  );
                }),
          )
        ],
      ),
    );
  }
}
