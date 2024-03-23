import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:clock_app/helpers/clock_helper.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

///ฟังก์ชันการสร้างการแจ้งเตือน
Future<void> alamSchedule(AlarmDataModel alarm) async {
  await AwesomeNotifications().initialize(null, [
    //สร้าง channel key ของการแจ้งเตือนนาฬิกาปลุก
    NotificationChannel(
      channelKey: 'scheduled',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.Max,
      defaultRingtoneType: DefaultRingtoneType.Alarm,
      enableVibration: true,
      playSound: true,
    ),
  ]);
  //สร้างการแจ้งเตือน('scheduled')
  await AwesomeNotifications().createNotification(
    schedule: NotificationCalendar(
      allowWhileIdle: true,
      year: alarm.time.year,
      month: alarm.time.month,
      day: alarm.time.day,
      hour: alarm.time.hour,
      minute: alarm.time.minute,
      preciseAlarm: true,
    ),
    content: NotificationContent(
      //simgple notification
      id: alarm.id,

      channelKey: 'scheduled', //set configuration wuth key "basic"
      title: 'Alarm at ${fromTimeToString(alarm.time)}',
      body: 'Ring Ring!!!',
      autoDismissible: false,
      displayOnBackground: true,
      displayOnForeground: true,
      wakeUpScreen: true,
      fullScreenIntent: true,
      notificationLayout: NotificationLayout.BigText,
      category: NotificationCategory.Alarm,
      criticalAlert: true,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'close',
        label: 'Close',
        enabled: true,
        actionType: ActionType.DismissAction,
        color: Colors.redAccent,
      ),
      NotificationActionButton(
        key: 'snooze',
        label: 'Snooze',
        enabled: true,
      )
    ],
  );
}

//ฟังก์ชันแสดงการแจ้งเตือนแบบเลื่อนปลุก
void snooze() {
  //นําเวลาล่าสุดมาเก็บใน snoozeTime
  DateTime snoozeTime = DateTime.now();
  //บวกเวลาsnoozeTime ไปอีก1นาที(เลื่อนปลุก1นาที)
  snoozeTime = snoozeTime.add(const Duration(minutes: 1));

  AwesomeNotifications().initialize(null, [
    //ฟังก์ชันการสร้างการแจ้งเตือนการเลื่อนปลุก
    NotificationChannel(
      channelKey: 'snooze',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for basic tests',
      channelShowBadge: true,
      importance: NotificationImportance.High,
      enableVibration: true,
      locked: true,
    ),
  ]);

  ///สร้างการแจ้งเตือนการเลื่อนปลุก(snooze)
  AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'snooze',
        title: 'snooze',
        body: 'Next alarm at ${fromTimeToString(snoozeTime)}',
        autoDismissible: false,
        displayOnBackground: true,
        displayOnForeground: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Reminder,
        actionType: ActionType.KeepOnTop,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'close_snooze',
          label: 'cancle',
          enabled: true,
        ),
      ]);
  //สร้างการแจ้งเตือน('scheduled')
  AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        allowWhileIdle: true,
        year: snoozeTime.year,
        month: snoozeTime.month,
        day: snoozeTime.day,
        hour: snoozeTime.hour,
        minute: snoozeTime.minute,
        preciseAlarm: true,
      ),
      content: NotificationContent(
        id: 20,
        channelKey: 'scheduled',
        title: 'Alarm again  at ${fromTimeToString(snoozeTime)}',
        body: 'Ring Ring!!!',
        autoDismissible: false,
        displayOnBackground: true,
        displayOnForeground: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        category: NotificationCategory.Alarm,
        criticalAlert: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'close',
          label: 'Close',
          enabled: true,
          actionType: ActionType.DismissAction,
          color: Colors.redAccent,
        ),
        NotificationActionButton(
          key: 'snooze',
          label: 'Snooze',
          enabled: true,
        )
      ]);
}
