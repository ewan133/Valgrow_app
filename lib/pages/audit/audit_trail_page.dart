import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class AuditTrailPage extends StatefulWidget {
  const AuditTrailPage({super.key});

  @override
  _AuditTrailPageState createState() => _AuditTrailPageState();
}

class _AuditTrailPageState extends State<AuditTrailPage> {
  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedEntityType;
  String? _selectedAction;
  String? _selectedUserId;
  bool _isFilterExpanded = false;

  // Filter options
  final List<String> _entityTypes = [
    'All',
    'transaction',
    'debt',
    'inventory',
    'customer',
    'expense',
    'promotion',
  ];

  final List<String> _actionTypes = [
    'All',
    'Sale',
    'Debt Sale',
    'Cash Sale',
    'Debt Fully Paid',
    'Partial Payment',
    'New Customer',
    'New Item',
    'Stock Added',
    'Stock Reduced',
    'Journal Created',
    'Journal Updated',
    'Journal Deleted',
    'Promotion Created',
    'Promotion Updated',
    'Promotion Deleted',
  ];

  // Map display names to actual action values
  final Map<String, String> _actionMapping = {
    'Sale': 'CREATE_TRANSACTION',
    'Debt Sale': 'CREATE_DEBT_TRANSACTION',
    'Cash Sale': 'CREATE_SALE_TRANSACTION',
    'Debt Fully Paid': 'DEBT_PAID_FULL',
    'Partial Payment': 'DEBT_PARTIAL_PAYMENT',
    'New Customer': 'CREATE_CUSTOMER',
    'New Item': 'CREATE_ITEM',
    'Stock Added': 'ADD_STOCK_BATCH',
    'Stock Reduced': 'REDUCE_STOCK',
    'Journal Created': 'CREATE_EXPENSE',
    'Journal Updated': 'UPDATE_EXPENSE',
    'Journal Deleted': 'DELETE_EXPENSE',
    'Promotion Created': 'CREATE_PROMOTION',
    'Promotion Updated': 'UPDATE_PROMOTION_STATUS',
    'Promotion Deleted': 'DELETE_PROMOTION',
  };

  // Colors
  static const Color primaryWhite = Colors.white;
  static const Color primaryBlack = Colors.black;
  static const Color accentGreen = Color(0xFF14AE5C);
  static const Color lightGray = Color(0xFFF6F6F6);
  static const Color subtleGray = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    // Set default date range to last 7 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(Duration(days: 7));

    // Load audit trail after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAuditTrail();
    });
  }

  Future<void> _loadAuditTrail() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);

    // Convert friendly action name back to database value
    String? actionValue;
    if (_selectedAction != null) {
      actionValue = _actionMapping[_selectedAction];
    }

    await provider.fetchAuditTrail(
      startDate: _startDate,
      endDate: _endDate,
      entityType: _selectedEntityType == 'All' ? null : _selectedEntityType,
      action: actionValue,
      userId: _selectedUserId,
      limit: 100,
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: accentGreen,
              surface: primaryWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadAuditTrail();
    }
  }

  void _applyFilters() {
    _loadAuditTrail();
  }

  void _clearFilters() {
    setState(() {
      _startDate = DateTime.now().subtract(Duration(days: 7));
      _endDate = DateTime.now();
      _selectedEntityType = null;
      _selectedAction = null;
      _selectedUserId = null;
    });
    _loadAuditTrail();
  }

  Color _getActionColor(String action) {
    if (action.contains('CREATE') || action.contains('ADD'))
      return Colors.green;
    if (action.contains('UPDATE')) return Colors.orange;
    if (action.contains('DELETE')) return Colors.red;
    if (action.contains('PAYMENT') || action.contains('PAID'))
      return Colors.blue;
    return accentGreen;
  }

  String _getFriendlyActionName(String action) {
    // Reverse mapping to get friendly name
    for (var entry in _actionMapping.entries) {
      if (entry.value == action) {
        return entry.key;
      }
    }
    // Fallback: format the action name nicely
    return action
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  IconData _getEntityIcon(String entityType) {
    switch (entityType.toLowerCase()) {
      case 'transaction':
        return Icons.shopping_cart;
      case 'debt':
        return Icons.account_balance_wallet;
      case 'inventory':
        return Icons.inventory_2;
      case 'customer':
        return Icons.person;
      case 'expense':
        return Icons.receipt_long;
      case 'promotion':
        return Icons.campaign;
      default:
        return Icons.description;
    }
  }

  String _getFriendlyEntityName(String entityType) {
    if (entityType.toLowerCase() == 'expense') {
      return 'Journal';
    }
    return entityType[0].toUpperCase() + entityType.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: MyAppbar(title: 'Audit Trail'),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingAuditLogs) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: accentGreen),
                  SizedBox(height: 16),
                  Text(
                    'Loading audit logs...',
                    style: TextStyle(color: subtleGray),
                  ),
                ],
              ),
            );
          }

          final auditLogs = provider.auditLogs;

          return Column(
            children: [
              // Filters Section
              _buildFiltersSection(provider),

              // Summary Stats
              _buildSummaryStats(auditLogs),

              // Audit Log List
              Expanded(
                child: auditLogs.isEmpty
                    ? _buildEmptyState()
                    : _buildAuditLogList(auditLogs),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersSection(DatabaseProvider provider) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isFilterExpanded = !_isFilterExpanded;
              });
            },
            child: Row(
              children: [
                Icon(Icons.filter_list, color: accentGreen, size: 20),
                SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryBlack,
                  ),
                ),
                Spacer(),
                if (!_isFilterExpanded &&
                    (_selectedEntityType != null || _selectedAction != null))
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        color: accentGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                Icon(
                  _isFilterExpanded ? Icons.expand_less : Icons.expand_more,
                  color: subtleGray,
                ),
              ],
            ),
          ),

          // Collapsible Filter Content
          if (_isFilterExpanded) ...[
            SizedBox(height: 12),
            Divider(color: subtleGray.withOpacity(0.2)),
            SizedBox(height: 12),

            // Clear Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear, size: 16, color: subtleGray),
                  label: Text('Clear', style: TextStyle(color: subtleGray)),
                ),
              ],
            ),

            // Date Range
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: subtleGray.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.date_range, color: accentGreen, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _startDate != null && _endDate != null
                            ? '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}'
                            : 'Select Date Range',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: subtleGray),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            // Entity Type & Action Dropdowns
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Entity Type',
                    value: _selectedEntityType,
                    items: _entityTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedEntityType = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Action',
                    value: _selectedAction,
                    items: _actionTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedAction = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: primaryWhite,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: subtleGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: subtleGray.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('All', style: TextStyle(fontSize: 14)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item == 'All' ? null : item,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(List<Map<String, dynamic>> auditLogs) {
    final Map<String, int> actionCounts = {};
    for (var log in auditLogs) {
      final action = log['action'] as String;
      actionCounts[action] = (actionCounts[action] ?? 0) + 1;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Activities',
                  '${auditLogs.length}',
                  Icons.analytics,
                  accentGreen,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Action Types',
                  '${actionCounts.length}',
                  Icons.category,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: subtleGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogList(List<Map<String, dynamic>> auditLogs) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: auditLogs.length,
      itemBuilder: (context, index) {
        final log = auditLogs[index];
        return _buildAuditLogCard(log);
      },
    );
  }

  Widget _buildAuditLogCard(Map<String, dynamic> log) {
    final action = log['action'] as String;
    final entityType = log['entityType'] as String;
    final userName = log['userName'] as String;
    final description = log['description'] as String;
    final timestamp = log['timestamp'] as DateTime;
    final metadata = log['metadata'] as Map<String, dynamic>? ?? {};

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getActionColor(action).withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getActionColor(action).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEntityIcon(entityType),
                    color: _getActionColor(action),
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFriendlyActionName(action),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getActionColor(action),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getFriendlyEntityName(entityType).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          color: subtleGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, HH:mm').format(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: subtleGray,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: subtleGray),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Description
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryBlack.withOpacity(0.8),
                  ),
                ),

                // Metadata (if any important fields)
                if (metadata.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subtleGray,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...metadata.entries.take(3).map((entry) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${entry.key}: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: subtleGray,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: primaryBlack,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: subtleGray.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No audit logs found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: subtleGray,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: subtleGray,
            ),
          ),
        ],
      ),
    );
  }
}
