import 'package:clock_app/helpers/clock_helper.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';
import 'package:clock_app/providers/alarm_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_app/theme.dart';

class ModifyAlarmScreenArg {
  final AlarmDataModel alarm;
  final int index;

  ModifyAlarmScreenArg(this.alarm, this.index);
}

class ModifyAlarmScreen extends StatefulWidget {
  static const routeName = '/modifyAlarm';

  final ModifyAlarmScreenArg? arg;

  const ModifyAlarmScreen({
    Key? key,
    this.arg,
  }) : super(key: key);

  @override
  State<ModifyAlarmScreen> createState() => _ModifyAlarmScreenState();
}

class _ModifyAlarmScreenState extends State<ModifyAlarmScreen> {
  late AlarmDataModel alarm = widget.arg?.alarm ??
      AlarmDataModel(
        time: DateTime.now(),
        weekdays: [],
      );

  bool get _editing => widget.arg?.alarm != null;

  @override
  Widget build(BuildContext context) {
    final dark = darkThemeData(context);
    return Theme(
      data : dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            (_editing ? 'Update' : 'Create') + ' Alarm',
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          leading: TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // Navigate back to the previous screen
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              primary: Colors.red, // Text color
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Button padding
              textStyle: TextStyle(fontSize: 16), // Text size
            ),
          ),
          leadingWidth: 100,
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final model = context.read<AlarmModel>();
                _editing
                    ? await model.updateAlarm(alarm, widget.arg!.index)
                    : await model.addAlarm(alarm);
                // Navigate back to the previous screen after saving
                Navigator.of(context).pop();

              },
              style: TextButton.styleFrom(
              primary: Colors.red, // Text color
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Button padding
              textStyle: TextStyle(fontSize: 16), // Text size
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness,
                    textTheme:  CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.white, // Set the text color to white
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    onDateTimeChanged: (value) {
                      setState(() {
                        alarm = alarm.copyWith(time: value);
                      });
                    },
                    initialDateTime: alarm.time,
                  ),
                ),
              ),
              ExpansionTile(
                title: Text(
                  'Repeat',
                ),
                trailing: Text(
                  alarm.weekdays.isEmpty
                      ? 'Never'
                      : alarm.weekdays.length == 7
                      ? 'Everyday'
                      : alarm.weekdays
                      .map((weekday) => fromWeekdayToStringShort(weekday))
                      .join(', '),
                  maxLines: 1,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                children: List.generate(7, (index) => index + 1).map((weekday) {
                  final checked = alarm.weekdays.contains(weekday);
                  return CheckboxListTile(
                      title: Text(
                        fromWeekdayToString(weekday),
                      ),
                      value: checked,
                      onChanged: (value) {
                        setState(() {
                          (value ?? false)
                              ? alarm.weekdays.add(weekday)
                              : alarm.weekdays.remove(weekday);
                        });
                      });
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
