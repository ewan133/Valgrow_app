import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/models/expenses_details.dart';

class EditExpensesModal extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpensesModal({super.key, required this.expense});

  @override
  State<EditExpensesModal> createState() => _EditExpensesModalState();
}

class _EditExpensesModalState extends State<EditExpensesModal> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  late String? _selectedCategory;

  final List<String> _categories = [
    'Electric Bill',
    'Water Bill',
    'Rent',
    'Internet Bill',
    'Mobile Load',
    'Transportation',
    'Employee Salary',
    'Snacks / Meals',
    'Maintenance',
  ];

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: widget.expense.amount.toString());
    _noteController = TextEditingController(text: widget.expense.note);
    _selectedDate = widget.expense.date;
    _selectedCategory = widget.expense.category;

    // Add custom category from DB if it's not in the default list
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory!);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = _amountController.text.trim();
    final note = _noteController.text.trim();
    final category = _selectedCategory;

    if (amount.isEmpty || category == null || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount and category are required")),
      );
      return;
    }

    Navigator.pop(context, {
      'expenseId': widget.expense.expenseId,
      'amount': double.tryParse(amount) ?? 0.0,
      'category': category,
      'note': note,
      'date': _selectedDate,
    });
  }

  void _showAddCategoryDialog() {
    final TextEditingController categoryInput = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: categoryInput,
          decoration: const InputDecoration(
            labelText: "New Category",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = categoryInput.text.trim();
              if (newCategory.isNotEmpty &&
                  !_categories.contains(newCategory)) {
                setState(() {
                  _categories.add(newCategory);
                  _selectedCategory = newCategory;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Record",
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: DateFormat('MMM d, yyyy').format(_selectedDate),
                    ),
                    decoration: InputDecoration(
                      labelText: "Date",
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedCategory,
                items: [
                  const DropdownMenuItem(
                    value: '__add_new__',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.green),
                        SizedBox(width: 8),
                        Text("Add new category"),
                      ],
                    ),
                  ),
                  ..._categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      )),
                ],
                onChanged: (value) {
                  if (value == '__add_new__') {
                    _showAddCategoryDialog();
                  } else {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                menuMaxHeight: 230,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Note (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child:
              const Text("Save Changes", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
