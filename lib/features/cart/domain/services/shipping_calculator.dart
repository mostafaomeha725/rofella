class ShippingCalculator {
  static const double defaultFee = 100.0;
  static const double reducedFee = 50.0;
  
  static const List<String> reducedFeeGovernorates = [
    'القاهرة',
    'الجيزة',
    'المنوفية',
  ];

  /// Returns the shipping fee based on the governorate.
  /// Returns null if no governorate is selected.
  static double? calculateShippingFee(String? governorate) {
    if (governorate == null || governorate.trim().isEmpty) {
      return null;
    }
    
    // Check if it's in the exact list or contains 'أكتوبر' for edge cases
    if (reducedFeeGovernorates.contains(governorate) || governorate.contains('أكتوبر')) {
      return reducedFee;
    }
    
    return defaultFee;
  }
}
