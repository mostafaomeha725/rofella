// import 'dart:async';

// class SignalRService {
//   final PreferencesStorage _storage;
//   HubConnection? _hubConnection;

//   final StreamController<NotificationEntity> _notificationController =
//       StreamController<NotificationEntity>.broadcast();

//   Stream<NotificationEntity> get notificationStream =>
//       _notificationController.stream;

//   SignalRService(this._storage);

//   Future<void> connect() async {
//     if (_hubConnection != null &&
//         _hubConnection!.state == HubConnectionState.Connected) {
//       safePrint("SignalR is already connected.");
//       return;
//     }

//     safePrint("SignalR Connecting...");

//     _hubConnection = HubConnectionBuilder()
//         .withUrl(
//           AppStrings.notificationHubUrl,
//           options: HttpConnectionOptions(
//             accessTokenFactory: () async {
//               // SignalR automatically uses this to get the token for connections and reconnections
//               final token = _storage.getUserToken();
//               return token ?? "";
//             },
//           ),
//         )
//         .withAutomaticReconnect()
//         .build();

//     _hubConnection?.onclose(({error}) {
//       safePrint("SignalR Disconnected. Error: $error");
//     });

//     _hubConnection?.onreconnecting(({error}) {
//       safePrint("SignalR Reconnecting... Error: $error");
//     });

//     _hubConnection?.onreconnected(({connectionId}) {
//       safePrint("SignalR Reconnected. ConnectionId: $connectionId");
//     });

//     _hubConnection?.on("ReceiveNotification", _onReceiveNotification);

//     try {
//       await _hubConnection?.start();
//       safePrint("SignalR Connected");
//     } catch (e) {
//       safePrint("SignalR Connection Error: $e");
//     }
//   }

//   void _onReceiveNotification(List<Object?>? parameters) {
//     if (parameters != null && parameters.isNotEmpty) {
//       safePrint("ReceiveNotification");
//       try {
//         final Map<String, dynamic> data =
//             parameters.first as Map<String, dynamic>;
//         final notification = NotificationModel.fromJson(data).toEntity();
//         _notificationController.add(notification);
//         safePrint("Notification Added");
//       } catch (e) {
//         safePrint("Error parsing SignalR Notification: $e");
//       }
//     }
//   }

//   Future<void> disconnect() async {
//     if (_hubConnection != null) {
//       safePrint("SignalR Disconnecting...");
//       _hubConnection?.off(
//         "ReceiveNotification",
//         method: _onReceiveNotification,
//       );
//       await _hubConnection?.stop();
//       safePrint("Logout -> SignalR Disconnected");
//     }
//   }

//   Future<void> reconnect() async {
//     await disconnect();
//     await connect();
//   }

//   void dispose() {
//     disconnect();
//     _notificationController.close();
//     safePrint("SignalR Disposed");
//   }
// }
