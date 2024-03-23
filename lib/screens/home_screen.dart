import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:clock_app/helpers/clock_helper.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';
import 'package:clock_app/providers/alarm_provider.dart';
import 'package:clock_app/screens/modify_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:clock_app/providers/model_prediction.dart';
import 'package:clock_app/theme.dart';
import '../providers/notification.dart';
import 'alarm_ar.dart';

class NotificationController {
  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      context, ReceivedAction receivedAction) async {
    if (receivedAction.buttonKeyPressed == 'snooze') {
      snooze();
    }
    if (receivedAction.buttonKeyPressed == 'close_snooze') {
      print('snooze stopped');
      AwesomeNotifications().cancel(20);

      ///move open alarm_ar to here code in home_screen.dart line69-72
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    print("notification displayed");
    if (receivedNotification.id == 20) {
      AwesomeNotifications().cancel(10);
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      context, ReceivedAction receivedAction) async {
    print("notification dismissed");
    AwesomeNotifications().cancel(receivedAction.id ?? 20);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UnityDemoScreen()),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showDeleteButtons = false;
  String sleepPredictionResult = '';
  String wakeupTime = '';
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) =>
          NotificationController.onActionReceivedMethod(
              context, receivedAction),
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: (ReceivedAction receivedAction) =>
          NotificationController.onDismissActionReceivedMethod(
              context, receivedAction),
    );
  }

  Widget build(BuildContext context) {
    final dark = darkThemeData(context);
    return Theme(
      data: dark,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          centerTitle: false,
          title: Text(
            'Shooting the Alarm',
            style: TextStyle(
              fontSize: 26,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(showDeleteButtons ? Icons.check : Icons.delete),
              onPressed: () {
                setState(() {
                  showDeleteButtons = !showDeleteButtons;
                });
              },
            ),
          ],
        ),
        body: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: 100,
              child: Stack(
                children: [
                  ///สร้างที่วางของการลากให้เป็นการpredictข้อมูล
                  Draggable(
                    data:
                        'Sleep Prediction  $sleepPredictionResult\nDrag and drop item to predict another',
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: const Color(0xFF333332),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (sleepPredictionResult.isNotEmpty)
                                  Text(
                                    sleepPredictionResult.isNotEmpty
                                        ? 'Sleep Time \n $sleepPredictionResult'
                                        : 'Drop Time Here',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (sleepPredictionResult.isEmpty)
                                  Text(
                                    'Drag Time Here',
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (sleepPredictionResult.isNotEmpty)
                                  Text(
                                    'Wake Up \n $wakeupTime',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    feedback: Positioned.fill(
                      child: Container(
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              'Drag to Predict',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///ถ้ารับข้อมูลแล้วให้ทําการpredictionข้อมูล
                  Positioned.fill(
                    child: DragTarget<AlarmDataModel>(
                      onAccept: (data) async {
                        // Handle the item being accepted in the drop area
                        String result = await sleepPredict(
                            data.time.hour, data.time.minute);
                        setState(() {
                          sleepPredictionResult = result;
                          wakeupTime =
                              wakeupFormat(data.time.hour, data.time.minute);
                        });
                      },

                      ///ถ้าลากมาที่ตําแหน่งนี้แล้วจะแสดงข้อความ "Drop Time Here"
                      builder: (context, candidateItems, rejectedItems) {
                        bool isDragOver = candidateItems.isNotEmpty;
                        return Container(
                          color: isDragOver
                              ? const Color(0xFF717171)
                              : Colors.transparent,
                          child: Center(
                            child: Text(
                              isDragOver ? 'Drop Time Here' : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100, // Adjust this value based on the height of the drop area
            left: 0,
            right: 0,
            bottom: 0,
            child: AlarmSheet(showDeleteButtons: showDeleteButtons),
          ),
        ]),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: FloatingActionButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FractionallySizedBox(
                    heightFactor: 0.9,
                    child: ModifyAlarmScreen(),
                  );
                },
              );
            },
            child: Icon(Icons.alarm_add),
            heroTag: 'fab',
            backgroundColor: Colors.red,
            elevation: 4,
            mini: false,
            shape: CircleBorder(),
            foregroundColor: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class AlarmSheet extends StatefulWidget {
  const AlarmSheet({
    Key? key,
    required this.showDeleteButtons,
  }) : super(key: key);

  final bool showDeleteButtons;

  @override
  State<AlarmSheet> createState() => _AlarmSheetState();
}

class _AlarmSheetState extends State<AlarmSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late AnimationController _controller;
  Animation<double>? animation;
  bool expanded = false;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      )..addListener(() {
          setState(() {});
        });

      animation = Tween(
        begin: getSmallSize(),
        end: getBigSize(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ));
    });

    super.initState();
  }

  double getBigSize() => MediaQuery.of(context).size.height * .8;

  double getSmallSize() {
    return MediaQuery.of(context).size.height * .8 -
        MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Wrap the Column around the Expanded widget
      children: [
        Expanded(
          // Place the Expanded widget inside the Column
          child: Selector<AlarmModel, AlarmModel>(
            shouldRebuild: (previous, next) {
              if (next.state is AlarmCreated) {
                final state = next.state as AlarmCreated;
                _listKey.currentState?.insertItem(state.index);
              } else if (next.state is AlarmUpdated) {
                final state = next.state as AlarmUpdated;
                if (state.index != state.newIndex) {
                  _listKey.currentState?.insertItem(state.newIndex);
                  _listKey.currentState?.removeItem(
                    state.index,
                    (context, animation) => CardAlarmItem(
                      alarm: state.alarm,
                      animation: animation,
                      showDeleteButton: widget.showDeleteButtons,
                    ),
                  );
                }
              }
              return true;
            },
            selector: (_, model) => model,
            builder: (context, model, child) {
              return Column(
                children: [
                  if (model.alarms != null)
                    Expanded(
                      // Place the Expanded widget inside the inner Column
                      child: AnimatedList(
                        key: _listKey,
                        shrinkWrap: true,
                        initialItemCount: model.alarms!.length,
                        itemBuilder: (context, index, animation) {
                          if (index >= model.alarms!.length) return Container();
                          final alarm = model.alarms![index];

                          return CardAlarmItem(
                            alarm: alarm,
                            animation: animation,
                            onDelete: () async {
                              _listKey.currentState?.removeItem(
                                index,
                                (context, animation) => CardAlarmItem(
                                  alarm: alarm,
                                  animation: animation,
                                  showDeleteButton: widget.showDeleteButtons,
                                ),
                              );
                              await model.deleteAlarm(alarm, index);
                            },
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.9,
                                    child: ModifyAlarmScreen(
                                      arg: ModifyAlarmScreenArg(alarm, index),
                                    ),
                                  );
                                },
                              );
                            },
                            showDeleteButton: widget.showDeleteButtons,
                          );
                        },
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class CardAlarmItem extends StatelessWidget {
  const CardAlarmItem({
    Key? key,
    required this.alarm,
    required this.animation,
    this.onDelete,
    this.onTap,
    required this.showDeleteButton,
  }) : super(key: key);

  final AlarmDataModel alarm;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Animation<double> animation;
  final bool showDeleteButton;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.98;

    ///ทําให้เวลานั้นสามารถลากเพิ่อไปใช้ในการPrediction
    return LongPressDraggable(
        // ใช้keyตาม alarm id
        key: ValueKey(alarm.id),
        data: alarm, // ส่งข้อมูลของalarmไปเมื่อลาก
        ///เมื่อทําการลาก ข้อมูลนั้นจะโปร่งใส
        feedback: Opacity(
          opacity: 0.5,

          ///ตั้งค่าขนาดของbox
          child: SizedBox(
              width: cardWidth,
              height: 100.0,
              child: Card(
                color: const Color(0xFF717171),
                child: ListTile(
                  title: Text(
                    fromTimeToString(alarm.time),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  subtitle: Text(
                    alarm.weekdays.isEmpty
                        ? 'Never'
                        : alarm.weekdays.length == 7
                            ? 'Everyday'
                            : alarm.weekdays
                                .map((weekday) =>
                                    fromWeekdayToStringShort(weekday))
                                .join(', '),
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  trailing: showDeleteButton
                      ? IconButton(
                          icon: const Icon(Icons.cancel),
                          color: Colors.red,
                          onPressed: () async {
                            if (onDelete != null) onDelete!();
                          },
                        )
                      : null,
                ),
              )),
        ),

        ///ตั้งค่าboxที่โดนลากให้เป็นสีเทา
        childWhenDragging: SizedBox(
            width: cardWidth,
            height: 100.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
            )),

        ///เมื่อยกเลิกการลากแล้ว ข้อมูลที่ถูกล่างจะกลับไปดังเดิม
        feedbackOffset: Offset(0, 10),
        child: SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: const Offset(0.0, 0.0),
              ).chain(CurveTween(curve: Curves.elasticInOut)),
            ),
            child: SizedBox(
                width: 100,
                height: 100.0,
                child: Card(
                  color: const Color(0xFF333332),
                  child: ListTile(
                    title: Text(
                      fromTimeToString(alarm.time),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      alarm.weekdays.isEmpty
                          ? 'Never'
                          : alarm.weekdays.length == 7
                              ? 'Everyday'
                              : alarm.weekdays
                                  .map((weekday) =>
                                      fromWeekdayToStringShort(weekday))
                                  .join(', '),
                      style: Theme.of(context).textTheme.bodyText2?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    trailing: showDeleteButton
                        ? IconButton(
                            icon: const Icon(Icons.cancel),
                            color: Colors.red,
                            onPressed: () async {
                              if (onDelete != null) onDelete!();
                            },
                          )
                        : null,
                    onTap: onTap,
                  ),
                ))));
  }
}

class TextIcon extends StatelessWidget {
  final Widget child;
  final String svgPath;

  const TextIcon({
    Key? key,
    required this.child,
    required this.svgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          svgPath,
          width: 20,
          height: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 11),
        child,
      ],
    );
  }
}
