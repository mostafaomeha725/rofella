// import 'dart:async';

// /// A simple broadcast stream that notifies screens to refresh
// /// based on the incoming notification type.
// ///
// /// Types:
// ///   1 = BranchUpdate   → refresh AdminHomeScreen + AdminBranchScreen
// ///   2 = SubscriptionUpdate → refresh AdminManageSubscriptionsScreen
// ///   5 = BranchPackagesUpdate → refresh ManagePackageScreen
// class NotificationRefreshService {
//   static final NotificationRefreshService _instance =
//       NotificationRefreshService._internal();

//   factory NotificationRefreshService() => _instance;
//   NotificationRefreshService._internal();

//   final _controller = StreamController<int>.broadcast();

//   /// Listen to this stream in your screens.
//   Stream<int> get stream => _controller.stream;

//   /// Called when a push/signalR notification arrives.
//   void notifyRefresh(int notificationType) {
//     if (!_controller.isClosed) {
//       _controller.add(notificationType);
//     }
//   }

//   void dispose() {
//     _controller.close();
//   }
// }
