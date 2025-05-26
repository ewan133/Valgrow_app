import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpensesModal extends StatefulWidget {
  const AddExpensesModal({super.key});

  @override
  State<AddExpensesModal> createState() => _AddExpensesModalState();
}

class _AddExpensesModalState extends State<AddExpensesModal> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
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

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now(); // Default to today

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
      title: const Text("Add Record",
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
                    decoration: InputDecoration(
                      labelText: "Date",
                      hintText:
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                      border: const OutlineInputBorder(),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: DateFormat('MMM d, yyyy').format(_selectedDate),
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
          child:  Text("Cancel",style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child:  Text("Save", style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}
