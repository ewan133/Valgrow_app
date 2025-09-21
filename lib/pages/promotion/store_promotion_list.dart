import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/promotion_database.dart';


class StorePromotionList extends StatefulWidget {
  const StorePromotionList({super.key});

  @override
  State<StorePromotionList> createState() => _StorePromotionListState();
}

class _StorePromotionListState extends State<StorePromotionList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PromotionDatabase _promotionDb = PromotionDatabase();
  
  List<Map<String, dynamic>> allPromotions = [];
  bool isLoading = true;
  String? error;

  // Color palette following 60-30-10 rule
  static const Color primaryWhite = Colors.white; // 60%
  static const Color primaryBlack = Colors.black; // 30%
  static const Color accentGreen = Color(0xFF14AE5C); // 10%
  static const Color lightGray = Color(0xFFF6F6F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPromotions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isPromotionActive(Map<String, dynamic> promotion) {
    final now = DateTime.now();
    final startDate = (promotion['start_date'] as Timestamp).toDate();
    final endDate = (promotion['end_date'] as Timestamp).toDate();
    
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  Future<void> _loadPromotions() async {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final storeId = provider.store?.storeId;
    
    if (storeId == null) {
      setState(() {
        error = 'Store ID not available';
        isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final promotions = await _promotionDb.fetchStorePromotions(storeId);
      
      setState(() {
        allPromotions = promotions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getPromotionsByStatus(String status) {
    switch (status) {
      case 'active':
        // Active: status is 'approved' AND within date range
        return allPromotions.where((promo) => 
          promo['status'] == 'approved' && _isPromotionActive(promo)
        ).toList();
      
      case 'pending':
        // Pending: status is 'pending' regardless of date
        return allPromotions.where((promo) => promo['status'] == 'pending').toList();
      
      case 'inactive':
        // Inactive: status is 'rejected' OR (status is 'approved' but outside date range)
        return allPromotions.where((promo) => 
          promo['status'] == 'rejected' || 
          (promo['status'] == 'approved' && !_isPromotionActive(promo))
        ).toList();
      
      default:
        return [];
    }
  }

  // Remove this method since we'll only use the status field from Firestore

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }

  String _formatAmount(double amount) {
    return "₱${amount.toStringAsFixed(0)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: AppBar(
        backgroundColor: accentGreen,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Store Promotions',
          style: TextStyle(
            color: primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryWhite),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: primaryWhite),
            onPressed: _loadPromotions,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: lightGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryWhite, // White text for selected tab
              unselectedLabelColor: primaryBlack.withOpacity(0.6),
              indicator: BoxDecoration(
                color: accentGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Active (${_getPromotionsByStatus('active').length})',
                      style: TextStyle(fontSize: 11)),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Pending (${_getPromotionsByStatus('pending').length})',
                      style: TextStyle(fontSize: 11)),
                  ),
                ),
                Tab(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Inactive (${_getPromotionsByStatus('inactive').length})',
                      style: TextStyle(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? _buildLoadingState()
          : error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPromotionList(_getPromotionsByStatus('active'), 'active'),
                    _buildPromotionList(_getPromotionsByStatus('pending'), 'pending'),
                    _buildPromotionList(_getPromotionsByStatus('inactive'), 'inactive'),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPromotionDialog();
        },
        backgroundColor: accentGreen,
        icon: Icon(Icons.add, color: primaryWhite),
        label: Text(
          'Add Promotion',
          style: TextStyle(
            color: primaryWhite,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: primaryWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(accentGreen),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading promotions...',
              style: TextStyle(
                color: primaryBlack.withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: primaryWhite,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.shade600,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Failed to load promotions',
                style: TextStyle(
                  color: primaryBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: primaryBlack.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loadPromotions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentGreen,
                  foregroundColor: primaryWhite,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Retry', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionList(List<Map<String, dynamic>> promotions, String type) {
    if (promotions.isEmpty) {
      return Container(
        color: primaryWhite,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.local_offer_outlined,
                    size: 48,
                    color: accentGreen,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'No ${type} promotions',
                  style: TextStyle(
                    color: primaryBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Promotions will appear here once added',
                  style: TextStyle(
                    color: primaryBlack.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: primaryWhite,
      child: RefreshIndicator(
        onRefresh: _loadPromotions,
        color: accentGreen,
        child: ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            return _buildPromotionCard(promotions[index], type);
          },
        ),
      ),
    );
  }

  Widget _buildPromotionCard(Map<String, dynamic> promotion, String type) {
    Color statusColor;
    
    // Determine display based on actual status and date range
    bool isWithinDateRange = _isPromotionActive(promotion);
    String actualStatus = promotion['status'] ?? 'unknown';
    
    switch (type) {
      case 'active':
        statusColor = accentGreen;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'inactive':
        if (actualStatus == 'approved' && !isWithinDateRange) {
          statusColor = Colors.red.withOpacity(0.6);
        } else if (actualStatus == 'rejected') {
          statusColor = Colors.red.withOpacity(0.7);
        } else {
          statusColor = primaryBlack.withOpacity(0.4);
        }
        break;
      default:
        statusColor = primaryBlack;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean promotion image header
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                // Promotion image
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: promotion['store_image'] != null
                      ? Image.network(
                          promotion['store_image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: lightGray,
                              child: Center(
                                child: Icon(
                                  Icons.store,
                                  color: primaryBlack.withOpacity(0.3),
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: lightGray,
                          child: Center(
                            child: Icon(
                              Icons.store,
                              color: primaryBlack.withOpacity(0.3),
                              size: 40,
                            ),
                          ),
                        ),
                ),
                // Simple status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: primaryWhite,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and amount
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        promotion['title'] ?? 'Untitled Promotion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      _formatAmount(promotion['amount']?.toDouble() ?? 0.0),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accentGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                
                // Description
                Text(
                  promotion['description'] ?? 'No description available',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryBlack.withOpacity(0.6),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 16),
                
                // Details row
                Row(
                  children: [
                    Expanded(
                      child: _buildSimpleDetailItem(
                        Icons.payment,
                        promotion['payment_method'] ?? 'Not specified',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildSimpleDetailItem(
                        Icons.calendar_today,
                        promotion['end_date'] != null 
                            ? _formatDate(promotion['end_date'])
                            : 'No end date',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Clean action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPromotionDetails(promotion);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGreen,
                      foregroundColor: primaryWhite,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDetailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: primaryBlack.withOpacity(0.5),
        ),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: primaryBlack.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showPromotionDetails(Map<String, dynamic> promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: primaryWhite,
        title: Text(
          promotion['title'] ?? 'Promotion Details',
          style: TextStyle(color: primaryBlack),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: primaryBlack,
              ),
            ),
            Text(
              promotion['description'] ?? 'No description',
              style: TextStyle(color: primaryBlack.withOpacity(0.7)),
            ),
            SizedBox(height: 12),
            Text(
              'Amount: ${_formatAmount(promotion['amount']?.toDouble() ?? 0.0)}',
              style: TextStyle(color: primaryBlack),
            ),
            SizedBox(height: 8),
            Text(
              'Start Date: ${promotion['start_date'] != null ? _formatDate(promotion['start_date']) : 'Not set'}',
              style: TextStyle(color: primaryBlack),
            ),
            SizedBox(height: 8),
            Text(
              'End Date: ${promotion['end_date'] != null ? _formatDate(promotion['end_date']) : 'Not set'}',
              style: TextStyle(color: primaryBlack),
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${promotion['status']}',
              style: TextStyle(color: primaryBlack),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: accentGreen)),
          ),
        ],
      ),
    );
  }

  void _showAddPromotionDialog() {
    // Navigate directly to promotion_form
    Navigator.pushNamed(context, '/store_promotion');
  }
}