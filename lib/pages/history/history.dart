import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/history_components.dart/date_container.dart';
import 'package:valgrow_ui/components/history_components.dart/history_tile.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('MMMM d, yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "History"),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromRGBO(20, 174, 92, 0.3),
          child: Column(
            children: [
              // Current date container
              Container(
                height: 57,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MyText(
                    text:
                        "As of $formattedDate", // Use formattedDate instead of now.toString()
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
        
              Column(
                children: [
                  MyDateContainer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                   MyDateContainer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ), MyDateContainer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: MyHistoryTile(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
