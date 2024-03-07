import 'package:clock_app/helpers/clock_helper.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';
import 'package:clock_app/providers/alarm_provider.dart';
import 'package:clock_app/providers/notification.dart';
import 'package:clock_app/screens/modify_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:clock_app/providers/model_prediction.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Stack(
          children:[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 100,
                child: Stack(
                  children: [
                    // Draggable for Sleep Prediction Result
                    Draggable(
                      data: 'Sleep Prediction  $sleepPredictionResult\nDrag and drop item to predict another',
                      child: Container(
                        width: double.infinity,
                        height: 100,
                        color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:[
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
                                      'Drag Time Here', // You need to replace this with the actual method to calculate wake-up time.
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
                                      'Wake Up \n $wakeupTime', // You need to replace this with the actual method to calculate wake-up time.
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
                    // DragTarget for Drop Area
                    Positioned.fill(
                      child: DragTarget<AlarmDataModel>(
                        onAccept: (data) async {
                          // Handle the item being accepted in the drop area
                          String result = await sleepPredict(data.time.hour, data.time.minute);
                          setState(() {
                            sleepPredictionResult = result;
                            wakeupTime =   wakeupFormat(data.time.hour,data.time.minute);
                          });
                        },
                        builder: (context, candidateItems, rejectedItems) {
                          bool isDragOver = candidateItems.isNotEmpty;
                          return Container(
                            color: isDragOver ? Colors.grey : Colors.transparent,
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
            ),]),
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
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

class _AlarmSheetState extends State<AlarmSheet> with SingleTickerProviderStateMixin {
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
    return Column( // Wrap the Column around the Expanded widget
      children: [
        Expanded( // Place the Expanded widget inside the Column
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
                    Expanded( // Place the Expanded widget inside the inner Column
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
    double cardWidth = screenWidth *0.98;
    return LongPressDraggable(
      // Add the key to ensure unique identification of each draggable item
      key: ValueKey(alarm.id),
      data: alarm, // Pass the alarm data as the drag data
      onDragStarted: () {
        // Add any necessary logic when dragging starts
      },
      onDraggableCanceled: (velocity, offset) {
        // Add any necessary logic when dragging is canceled
      },
      feedback: Opacity(
        opacity: 0.5,
        child: SizedBox(
            width: cardWidth, // Set a fixed width or use constraints as needed
            height: 100.0, child: Card(
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
                  .map((weekday) => fromWeekdayToStringShort(weekday))
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
      childWhenDragging: SizedBox( width: cardWidth,
        height: 100.0, child: Container(
    decoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.5),
    borderRadius: BorderRadius.circular(10.0),
    ),)),
      feedbackOffset: Offset(0, 10),
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: const Offset(0.0, 0.0),
          ).chain(CurveTween(curve: Curves.elasticInOut)),
        ),
        child: SizedBox(
    width: 100, // Set a fixed width or use constraints as needed
    height: 100.0,
    child: Card(
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
        ),
      ),
      ));
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

