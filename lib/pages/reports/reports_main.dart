import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/datepicker.dart';
import 'package:valgrow_ui/components/reports_components/sales_table.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class ReportsMainPage extends StatefulWidget {
  const ReportsMainPage({super.key});

  @override
  State<ReportsMainPage> createState() => _ReportsMainPageState();
}

class _ReportsMainPageState extends State<ReportsMainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Reports"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                    child: MyDatePicker(
                  label: "Start Date",
                )),
                SizedBox(
                  width: 20,
                ),
                Expanded(child: MyDatePicker(label: "End Date"))
              ],
            ),
            SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: MyButton(
                text: "Generate Report",
                color: Color(0xFF14AE5C),
                width: double.infinity,
                borderRadius: 999,
                onTap: () => {},
              ),
            ),
            SizedBox(height: 30,),
            MyText(text: "Sales Report", fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500),
            SizedBox(height: 5,),
            MySalesTable(),

          ],
        ),
      ),
    );
  }
}
