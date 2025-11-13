import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/services/database/promotion_database.dart';
import 'package:valgrow_ui/services/storage/storage_service.dart';

// Admin Configuration Class - Fallback defaults
class PromotionConfig {
  static const double DEFAULT_PRICE_PER_DAY = 15.0;
  static const int DEFAULT_MIN_DAYS = 7;
  static const List<String> DEFAULT_PAYMENT_METHODS = [
    'GCash',
    'Maya',
    'Bank Transfer'
  ];
}

class StorePromotionForm extends StatefulWidget {
  @override
  _StorePromotionFormState createState() => _StorePromotionFormState();
}

class _StorePromotionFormState extends State<StorePromotionForm> {
  // Form and UI Controllers
  final _part1FormKey = GlobalKey<FormState>();
  final _part2FormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Form Data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _receiptImage;
  File? _storeImage;

  // Date and pricing
  DateTime? _startDate;
  DateTime? _endDate;
  double _calculatedAmount = 0.0;
  int _selectedDays = 0;
  double _pricePerDay = 0.0;
  int _minDays = 7;
  List<String> _paymentMethods = [];
  Map<String, dynamic> _paymentMethodDetails = {};

  // Form state
  int _currentStep = 0;
  String _selectedPaymentMethod = '';
  bool _isLoadingConfig = true;

  // Professional Color Palette (60-30-10 rule)
  static const Color primaryWhite = Colors.white; // 60% - Primary background
  static const Color primaryBlack = Colors.black; // 30% - Text and UI elements
  static const Color accentGreen = Color(0xFF14AE5C); // 10% - Accent color
  static const Color lightGray = Color(0xFFF6F6F6); // Supporting color
  static const Color subtleGray = Color(0xFF9E9E9E); // Subtle text

  @override
  void initState() {
    super.initState();
    _loadPromotionPricing();
  }

  Future<void> _loadPromotionPricing() async {
    try {
      // Get store's barangay from database provider
      final store = Provider.of<DatabaseProvider>(context, listen: false).store;

      if (store == null) {
        throw Exception('Store information not available');
      }

      // Get barangay from store's address or barangay field
      String barangay = store.barangay;

      if (barangay.isEmpty) {
        throw Exception('Store barangay not found');
      }

      print("🔍 Loading promotion config for barangay: $barangay");

      final config = await PromotionDatabase().fetchPromotionConfig(barangay);
      setState(() {
        _pricePerDay = config['price_per_day']?.toDouble() ??
            PromotionConfig.DEFAULT_PRICE_PER_DAY;
        _minDays = config['min_days'] ?? PromotionConfig.DEFAULT_MIN_DAYS;

        // Extract payment methods with index-based approach
        final methods = config['payment_methods'] as List<dynamic>? ?? [];
        _paymentMethods = [];
        _paymentMethodDetails = {};

        // Build payment method details map with index-based keys
        for (int i = 0; i < methods.length; i++) {
          final method = methods[i];
          final methodKey = '${method['type']}_$i'; // Use index to make unique
          _paymentMethods.add(methodKey);
          _paymentMethodDetails[methodKey] = {
            'type': method['type'], // Store original type name
            'qr_code': method['qrCode'] ?? '',
            'account_number': method['accountNumber'] ?? '',
            'id': method['id'],
            'index': i,
          };
        }

        _isLoadingConfig = false;

        print("✅ Loaded ${_paymentMethods.length} payment methods");
      });
    } catch (e) {
      print("❌ Error loading promotion pricing: $e");
      setState(() {
        _pricePerDay = 0.0;
        _minDays = 0;
        _paymentMethods = [];
        _paymentMethodDetails = {};
        _isLoadingConfig = false;
      });

      // Show error to user
      Fluttertoast.showToast(
        msg:
            'Promotion feature is not available. Rules and payment methods are not configured.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _calculateAmount() {
    if (_startDate != null && _endDate != null && _pricePerDay > 0) {
      final days = _endDate!.difference(_startDate!).inDays + 1;

      // Check minimum days requirement
      if (days < _minDays) {
        Fluttertoast.showToast(
          msg: 'Minimum promotion period is $_minDays days',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      setState(() {
        _selectedDays = days;
        _calculatedAmount = days * _pricePerDay;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
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
      _calculateAmount();
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_part1FormKey.currentState!.validate() &&
          _startDate != null &&
          _endDate != null &&
          _storeImage != null) {
        setState(() {
          _currentStep = 1;
        });
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Please fill in all required fields in Part 1',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      setState(() {
        _currentStep = 0;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() async {
    if (!_part2FormKey.currentState!.validate()) return;

    if (_receiptImage == null) {
      Fluttertoast.showToast(
        msg: 'Please upload payment receipt',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_selectedPaymentMethod.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select a payment method',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    _showLoadingDialog();

    try {
      final store = Provider.of<DatabaseProvider>(context, listen: false).store;
      if (store == null) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Store information not found',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Upload images
      String receiptUrl = '';
      String storeImageUrl = '';

      if (_receiptImage != null) {
        String imageName = 'receipt_${DateTime.now().millisecondsSinceEpoch}';
        receiptUrl = await Provider.of<StorageService>(context, listen: false)
                .uploadImage(_receiptImage!, imageName, context) ??
            '';
      }

      if (_storeImage != null) {
        String imageName = 'store_${DateTime.now().millisecondsSinceEpoch}';
        storeImageUrl =
            await Provider.of<StorageService>(context, listen: false)
                    .uploadImage(_storeImage!, imageName, context) ??
                '';
      }

      if (receiptUrl.isEmpty || storeImageUrl.isEmpty) {
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: 'Failed to upload images',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      await PromotionDatabase().addPromotion(
        receiptImageUrl: receiptUrl,
        storeImageUrl: storeImageUrl,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        amount: _calculatedAmount,
        storeId: store.storeId,
        status: 'pending',
        startDate: _startDate,
        endDate: _endDate,
        paymentMethod: _selectedPaymentMethod,
      );

      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Promotion submitted successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      _resetForm();
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Error submitting promotion: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _resetForm() {
    setState(() {
      _receiptImage = null;
      _storeImage = null;
      _startDate = null;
      _endDate = null;
      _calculatedAmount = 0.0;
      _selectedDays = 0;
      _selectedPaymentMethod = '';
      _currentStep = 0;
      _titleController.clear();
      _descriptionController.clear();
    });
    _pageController.animateToPage(
      0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(24),
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryBlack.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: accentGreen,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Submitting promotion...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseImageSource(bool isReceipt) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: primaryWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: subtleGray.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryBlack,
                ),
              ),
              SizedBox(height: 24),
              _buildImageSourceTile(
                icon: Icons.camera_alt,
                title: "Take a Photo",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isReceipt);
                },
              ),
              _buildImageSourceTile(
                icon: Icons.photo_library,
                title: "Choose from Gallery",
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isReceipt);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentGreen, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: primaryBlack,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isReceipt) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          if (isReceipt) {
            _receiptImage = File(pickedFile.path);
          } else {
            _storeImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to pick image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
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
      child: Row(
        children: [
          _buildStepCircle(0, 'Promotion Info'),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _currentStep >= 1
                    ? accentGreen
                    : subtleGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _buildStepCircle(1, 'Payment Receipt'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted || isActive
                ? accentGreen
                : subtleGray.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: primaryWhite, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryWhite,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? accentGreen : subtleGray,
          ),
        ),
      ],
    );
  }

  // PART 1: Promotion Information
  Widget _buildPart1() {
    return Form(
      key: _part1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.campaign, size: 24, color: accentGreen),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promotion Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Set up your promotion information and pricing',
                        style: TextStyle(color: subtleGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Current Rates Section
          if (_isLoadingConfig)
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: primaryWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: accentGreen),
                    SizedBox(height: 16),
                    Text(
                      'Loading promotion rates...',
                      style: TextStyle(
                        color: subtleGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_pricePerDay <= 0 || _minDays <= 0)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Promotion feature is not available. Rules and payment methods are not configured for your barangay.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentGreen.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: accentGreen, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Current Promotion Rates',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accentGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rate per day:',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtleGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '₱${_pricePerDay.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: accentGreen,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Minimum days:',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtleGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$_minDays days',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryBlack,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 24),

          // Store Image Upload
          Text(
            'Store Photo *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
          SizedBox(height: 12),
          _buildImageUploadCard(
            title: 'Store Photo',
            icon: Icons.store,
            image: _storeImage,
            onTap: () => _chooseImageSource(false),
          ),
          SizedBox(height: 24),

          // Date Range Section
          _buildDateRangeCard(),
          SizedBox(height: 24),

          // Form Fields
          Text(
            'Promotion Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
          SizedBox(height: 12),

          _buildInputField(
            controller: _titleController,
            label: 'Promotion Title',
            icon: Icons.title,
            validator: (value) =>
                value?.isEmpty == true ? 'Please enter promotion title' : null,
          ),
          SizedBox(height: 16),

          _buildInputField(
            controller: _descriptionController,
            label: 'Promotion Description',
            icon: Icons.description,
            maxLines: 3,
            validator: (value) => value?.isEmpty == true
                ? 'Please enter promotion description'
                : null,
          ),
        ],
      ),
    );
  }

  // PART 2: Payment Receipt
  Widget _buildPart2() {
    return Form(
      key: _part2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.payment, size: 24, color: accentGreen),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment & Receipt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select payment method and upload your receipt',
                        style: TextStyle(color: subtleGray, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Total Amount Summary
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: accentGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentGreen.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount to Pay:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryBlack,
                      ),
                    ),
                    Text(
                      '₱${_calculatedAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: accentGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '$_selectedDays days × ₱${_pricePerDay.toStringAsFixed(2)} per day',
                  style: TextStyle(
                    fontSize: 12,
                    color: subtleGray,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Payment Methods
          Text(
            'Select Payment Method *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
          SizedBox(height: 12),

          if (_isLoadingConfig)
            Container(
              padding: EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: primaryWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: accentGreen),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment methods...',
                      style: TextStyle(
                        color: subtleGray,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_paymentMethods.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Promotion feature is not available. Payment methods and rules are not configured for your barangay.',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._paymentMethods
                .map((method) => _buildPaymentMethodCard(method))
                .toList(),

          SizedBox(height: 24),

          // Payment Receipt Upload
          Text(
            'Upload Payment Receipt *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: primaryBlack,
            ),
          ),
          SizedBox(height: 12),
          _buildImageUploadCard(
            title: 'Payment Receipt',
            icon: Icons.receipt_long,
            image: _receiptImage,
            onTap: () => _chooseImageSource(true),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String methodKey) {
    final isSelected = _selectedPaymentMethod == methodKey;

    // Get payment method details from database config
    final methodDetails = _paymentMethodDetails[methodKey] ?? {};
    final methodType = methodDetails['type'] ?? methodKey; // Display name
    final methodIndex = methodDetails['index'] ?? 0;
    final qrUrl = methodDetails['qr_code'] ?? '';
    final accountNumber = methodDetails['account_number'] ?? 'N/A';

    // Create unique key for each payment method to ensure different images
    final uniqueKey = '${methodKey}_${qrUrl}_${accountNumber}';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? accentGreen : subtleGray.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = methodKey;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? accentGreen : subtleGray,
                          width: 2,
                        ),
                        color: isSelected ? accentGreen : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 12, color: primaryWhite)
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            methodType,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryBlack,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#${methodIndex + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: accentGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isSelected && methodDetails.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightGray,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text('Account Number: $accountNumber',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryBlack)),
                        if (qrUrl.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text('QR Code:',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: primaryBlack)),
                          SizedBox(height: 8),
                          Center(
                            child: Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: qrUrl.startsWith('http')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        qrUrl,
                                        key: ValueKey(
                                            uniqueKey), // Unique key for each image
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.error,
                                                    size: 40,
                                                    color: subtleGray),
                                                SizedBox(height: 8),
                                                Text('QR Failed',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: subtleGray)),
                                                SizedBox(height: 4),
                                                Text(
                                                    '${methodType} #${methodIndex + 1}',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        color: subtleGray)),
                                              ],
                                            ),
                                          );
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: accentGreen,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                                SizedBox(height: 8),
                                                Text('Loading QR...',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: subtleGray)),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.qr_code,
                                              size: 60, color: subtleGray),
                                          SizedBox(height: 8),
                                          Text('QR Code',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: subtleGray)),
                                          SizedBox(height: 4),
                                          Text(
                                              '${methodType} #${methodIndex + 1}',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: subtleGray)),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (isSelected && methodDetails.isEmpty) ...[
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Payment details not configured for this method.',
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Container(
      padding: EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(Icons.calendar_today, color: accentGreen, size: 18),
              SizedBox(width: 8),
              Text(
                'Promotion Period *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryBlack,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectDateRange,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: primaryWhite,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Select Dates',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_startDate != null && _endDate != null) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                      Icon(Icons.arrow_forward, color: accentGreen, size: 16),
                      Text(
                        '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_selectedDays days × ₱${_pricePerDay.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtleGray,
                        ),
                      ),
                      Text(
                        '₱${_calculatedAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: accentGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageUploadCard({
    required String title,
    required IconData icon,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image == null
              ? subtleGray.withOpacity(0.3)
              : accentGreen.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: image != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryBlack.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.edit, color: primaryWhite, size: 14),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, size: 24, color: accentGreen),
                    ),
                    SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryBlack,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap to upload',
                      style: TextStyle(fontSize: 12, color: subtleGray),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: subtleGray),
        prefixIcon: Icon(icon, color: accentGreen, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: subtleGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentGreen, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: subtleGray.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: primaryWhite,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: primaryBlack),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryWhite,
        boxShadow: [
          BoxShadow(
            color: primaryBlack.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentGreen),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accentGreen,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 0 ? _nextStep : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: primaryWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _currentStep == 0 ? 'Next' : 'Submit',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryWhite,
      appBar: MyAppbar(
        title: 'Promotion',
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: _buildPart1(),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: _buildPart2(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
