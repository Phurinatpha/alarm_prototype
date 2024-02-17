import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wakelock/wakelock.dart';
import 'package:clock_app/providers/alarm_provider.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';

class AlarmScreen extends StatelessWidget {
  static const routeName = '/alarmScreen';
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final format = DateFormat('Hm');

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Container(
              width: 325,
              height: 325,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: Colors.red,
                    size: 32,
                  ),
                  Text(
                    format.format(now),
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: Colors.black),
                  ),
                  Text(
                    "Time to wake now!",
                    style: TextStyle(color: Colors.black, fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SlideAction(
              height: 80,
              sliderButtonIcon: Icon(
                Icons.chevron_right,
                size: 36,
              ),
              child: Center(
                  child: Text(
                'Turn off alarm!',
                style: TextStyle(fontSize: 26, color: Colors.white),
              )),
              onSubmit: () async {
                Wakelock.disable();

                SystemNavigator.pop();
              },
              textColor: Colors.black,
              innerColor: Colors.white,
              outerColor: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
