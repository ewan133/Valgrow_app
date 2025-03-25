import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class EmployeeCards extends StatefulWidget {
  final UserProfile employee;

  const EmployeeCards({super.key, required this.employee});

  @override
  State<EmployeeCards> createState() => _EmployeeCardsState();
}

class _EmployeeCardsState extends State<EmployeeCards> {
  late bool imsPermission;
  late bool posPermission;
  late bool debtsPermission;
  late bool reportsPermission;
  late bool expensesPermission; // ✅ Added Expenses Permission
  bool _isUpdating = false; // ✅ Loading state for toggles
  bool _isRemoving = false; // ✅ Loading state for removing employee

  @override
  void initState() {
    super.initState();
    imsPermission = widget.employee.ims;
    posPermission = widget.employee.pos;
    debtsPermission = widget.employee.debts;
    reportsPermission = widget.employee.reports;
    expensesPermission = widget.employee.expenses; // ✅ Initialize Expenses
  }

  /// 🔹 Function to update permission with confirmation
  Future<void> _updatePermission(String permissionType, bool newValue) async {
    if (_isUpdating) return; // Prevent multiple clicks during update

    bool? confirm = await _showPermissionConfirmation(permissionType, newValue);
    if (confirm != true) return;

    setState(() => _isUpdating = true); // Show loading

    String field = "";
    if (permissionType == "Inventory") field = "ims";
    if (permissionType == "POS") field = "pos";
    if (permissionType == "Debts") field = "debts";
    if (permissionType == "Reports") field = "reports";
    if (permissionType == "Expenses") field = "expenses"; // ✅ Added Expenses

    try {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .updateEmployeePermission(
        userId: widget.employee.uid,
        permissionField: field,
        newValue: newValue,
      );

      // ✅ Update UI after successful Firebase update
      setState(() {
        if (permissionType == "Inventory") imsPermission = newValue;
        if (permissionType == "POS") posPermission = newValue;
        if (permissionType == "Debts") debtsPermission = newValue;
        if (permissionType == "Reports") reportsPermission = newValue;
        if (permissionType == "Expenses") expensesPermission = newValue;
      });

      print("✅ Updated $permissionType: $newValue");
    } catch (e) {
      print("❌ Error updating $permissionType: $e");
    } finally {
      setState(() => _isUpdating = false); // Hide loading
    }
  }

  /// 🔹 Show confirmation dialog before changing permission
  Future<bool?> _showPermissionConfirmation(
      String permissionType, bool newValue) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Permission Change"),
          content: Text(
              "Are you sure you want to ${newValue ? "enable" : "disable"} $permissionType for ${widget.employee.name}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Function to confirm before removing employee
  Future<void> _removeEmployee() async {
    bool? confirm = await _showRemoveConfirmation();
    if (confirm != true) return;

    setState(() => _isRemoving = true); // ✅ Show loading

    try {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .removeEmployee(widget.employee.uid); // ✅ Call provider method

      print("✅ Employee removed: ${widget.employee.name}");
    } catch (e) {
      print("❌ Error removing employee: $e");
    } finally {
      setState(() => _isRemoving = false); // ✅ Hide loading
    }
  }

  /// 🔹 Show confirmation dialog before removing employee
  Future<bool?> _showRemoveConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Employee"),
          content: Text(
              "Are you sure you want to remove ${widget.employee.name}? This will unassign them from the store."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("Remove", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Employee Details
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.employee.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "📞 ${widget.employee.phone}",
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        "Role: ${widget.employee.role}",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                _isRemoving
                    ? const CircularProgressIndicator() // ✅ Show loader when removing
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _removeEmployee,
                      ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 20, thickness: 1),

            // ✅ Permissions Toggle Section
            const Text(
              "Permissions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildPermissionRow("Inventory", imsPermission,
                (val) => _updatePermission("Inventory", val)),
            _buildPermissionRow(
                "POS", posPermission, (val) => _updatePermission("POS", val)),
            _buildPermissionRow("Debts", debtsPermission,
                (val) => _updatePermission("Debts", val)),
            _buildPermissionRow("Reports", reportsPermission,
                (val) => _updatePermission("Reports", val)),
            _buildPermissionRow(
                "Expenses",
                expensesPermission,
                (val) =>
                    _updatePermission("Expenses", val)), // ✅ Added Expenses Row
          ],
        ),
      ),
    );
  }

  /// 🔹 Build a row for each permission toggle
  Widget _buildPermissionRow(
      String label, bool currentValue, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          _isUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: currentValue,
                  onChanged: onChanged,
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.grey[300],
                ),
        ],
      ),
    );
  }
}
