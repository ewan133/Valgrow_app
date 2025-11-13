import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/models/expenses_details.dart';
import 'package:intl/intl.dart';

class MyExpensesInfoList extends StatefulWidget {
  final ExpenseModel expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MyExpensesInfoList({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MyExpensesInfoList> createState() => _MyExpensesInfoListState();
}

class _MyExpensesInfoListState extends State<MyExpensesInfoList> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat("MMMM dd, yyyy").format(widget.expense.date);
    final hasNote = widget.expense.note?.trim().isNotEmpty ?? false;

    return Slidable(
      key: Key(widget.expense.expenseId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.35,
        children: [
          CustomSlidableAction(
            onPressed: (_) => widget.onEdit?.call(),
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => widget.onDelete?.call(),
            padding: const EdgeInsets.all(0),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: formattedDate,
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: "Type",
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    MyText(
                      text: widget.expense.category,
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText(
                      text: "Amount",
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                    MyText(
                      text: "₱${widget.expense.amount.toStringAsFixed(2)}",
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ],
            ),

            // Show expand/collapse button if there's a note
            if (hasNote) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isExpanded ? "Hide Note" : "View Note",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Collapsible note section
            if (_isExpanded && hasNote) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Note:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.expense.note!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
