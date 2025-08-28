import 'package:flutter/material.dart';

// Paid Keys
final GlobalKey unpaidTabKey = GlobalKey();
final GlobalKey paidTabKey = GlobalKey();
final GlobalKey totalAmountKey = GlobalKey();
final GlobalKey receivedAmountKey = GlobalKey();
final GlobalKey changeAmountKey = GlobalKey();
final GlobalKey paymentMethodKey = GlobalKey();
final GlobalKey confirmButtonKey = GlobalKey();


// Unpaid Keys
final GlobalKey totalUnpaidAmountKey = GlobalKey();
final GlobalKey unpaidReceivedAmountKey = GlobalKey();
final GlobalKey unpaidPaymentMethodKey = GlobalKey();
final GlobalKey unpaidBalanceKey = GlobalKey();
final GlobalKey selectCustomerKey = GlobalKey();
final GlobalKey setUnpaidDuedateKey = GlobalKey();
final GlobalKey unpaidSaveButtonKey = GlobalKey();

// Main Debts Keys
final GlobalKey mainDebtsSearch = GlobalKey();
final GlobalKey mainDebtsList = GlobalKey(); // not used

// Main Inventory
final GlobalKey mainInventoryFilter = GlobalKey(debugLabel: "mainInventoryFilter");
final GlobalKey mainInventoryAddButton = GlobalKey(debugLabel: "mainInventoryAddButton");
final GlobalKey mainInventorySearchbar  = GlobalKey(debugLabel: "mainInventorySearchbar");
final GlobalKey mainInventoryProductList  = GlobalKey(debugLabel: "mainInventoryProductList"); // not used

// Inventory Item Details keys

final GlobalKey itemDetailsEdit  = GlobalKey();
final GlobalKey itemDetailsAddStock  = GlobalKey(); 
final GlobalKey itemDetailsImage  = GlobalKey(); 
final GlobalKey itemDetails  = GlobalKey(); 

// Add Product Keys
final GlobalKey addItemImage  = GlobalKey(); 
final GlobalKey addItemName  = GlobalKey(); 
final GlobalKey addItemRegularPrice  = GlobalKey(); 
final GlobalKey addItemUnpaidPrice  = GlobalKey(); 
final GlobalKey addItemCategory  = GlobalKey(); 
final GlobalKey addItemUnit  = GlobalKey(); 
final GlobalKey addItemBarcode  = GlobalKey(); 
final GlobalKey addItemSaveButton  = GlobalKey(); 

// Debts Personal List Details
final GlobalKey DebtsPersonalEdit  = GlobalKey(); 
final GlobalKey DebtsPersonalDetails  = GlobalKey(); 
final GlobalKey DebtsPersonalListKey  = GlobalKey(); 
final GlobalKey DebtsPersonalReport  = GlobalKey(); 




