import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/services/notification_action.dart';
import 'package:life_tracker/core/services/notification_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notification_service_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  group('NotificationService', () {
    late NotificationService notificationService;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;

    setUp(() {
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      notificationService =
          NotificationService.internal(mockFlutterLocalNotificationsPlugin);
      when(
        mockFlutterLocalNotificationsPlugin.initialize(
          any,
          onDidReceiveNotificationResponse:
              anyNamed('onDidReceiveNotificationResponse'),
        ),
      ).thenAnswer((_) async => true);
    });

    test('scheduleNotification should schedule a notification with actions',
        () async {
      final actions = [
        const NotificationAction(id: 'action1', label: 'Action 1'),
        const NotificationAction(id: 'action2', label: 'Action 2'),
      ];

      await notificationService.scheduleNotification(
        id: 1,
        title: 'Test Title',
        body: 'Test Body',
        scheduledDate: DateTime.now().add(const Duration(seconds: 10)),
        actions: actions,
      );

      final captured = verify(
        mockFlutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'Test Title',
          'Test Body',
          any,
          captureAny,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: anyNamed('payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android!.actions!.length, 2);
      expect(details.android!.actions![0].id, 'action1');
      expect(details.android!.actions![0].title, 'Action 1');
      expect(details.android!.actions![1].id, 'action2');
      expect(details.android!.actions![1].title, 'Action 2');
    });

    test('cancelNotification should cancel a specific notification', () async {
      when(mockFlutterLocalNotificationsPlugin.cancel(any))
          .thenAnswer((_) async {});

      await notificationService.cancelNotification(42);

      verify(mockFlutterLocalNotificationsPlugin.cancel(42)).called(1);
    });

    test('cancelAllNotifications should cancel all notifications', () async {
      when(mockFlutterLocalNotificationsPlugin.cancelAll())
          .thenAnswer((_) async {});

      await notificationService.cancelAllNotifications();

      verify(mockFlutterLocalNotificationsPlugin.cancelAll()).called(1);
    });

    test('showImmediateNotification should show notification immediately',
        () async {
      when(
        mockFlutterLocalNotificationsPlugin.show(
          any,
          any,
          any,
          any,
          payload: anyNamed('payload'),
        ),
      ).thenAnswer((_) async {});

      final result = await notificationService.showImmediateNotification(
        id: 100,
        title: 'Immediate Title',
        body: 'Immediate Body',
        payload: 'test_payload',
      );

      expect(result, isTrue);
      verify(
        mockFlutterLocalNotificationsPlugin.show(
          100,
          'Immediate Title',
          'Immediate Body',
          any,
          payload: 'test_payload',
        ),
      ).called(1);
    });
  });
}
