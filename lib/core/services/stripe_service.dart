// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

// class StripeService {
//   Future<void> initPaymentSheet({
//     required String paymentIntentClientSecret,
//   }) async {
//     await Stripe.instance.initPaymentSheet(
//       paymentSheetParameters: SetupPaymentSheetParameters(
//         paymentIntentClientSecret: paymentIntentClientSecret,
//         merchantDisplayName: 'GymBook',
//         style: ThemeMode.light,
//       ),
//     );
//   }

//   Future<void> presentPaymentSheet() async {
//     await Stripe.instance.presentPaymentSheet();
//   }
// }
