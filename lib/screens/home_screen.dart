import 'package:clock_app/helpers/clock_helper.dart';
import 'package:clock_app/models/data_models/alarm_data_model.dart';
import 'package:clock_app/providers/alarm_provider.dart';
import 'package:clock_app/screens/modify_alarm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Shooting the Alarm',
          style: TextStyle(
            fontSize: 26, //
          ),
        ),
      ),
      body: AlarmSheet(), // Your main content goes here
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 15.0), // Adjust bottom padding as needed
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return FractionallySizedBox(
                  heightFactor: 0.9, // Show half of the screen
                  child: ModifyAlarmScreen(),
                );
              },
            );
          },
          child: Icon(Icons.alarm_add),
          heroTag: 'fab', // Customize the hero tag to ensure proper animations
          backgroundColor: Colors.red, // Customize the FAB color
          elevation: 4, // Add elevation for a raised effect
          mini: false, // Ensure the FAB is not mini
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
  }) : super(key: key);

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
    return Expanded(
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
                Expanded( // Ensure the list takes up all available space
                  child: AnimatedList(
                    key: _listKey,
                    // not recommended for a list with large number of items
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
                            ),
                          );
                          await model.deleteAlarm(alarm, index);
                        },
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.9, // Show half of the screen
                                child: ModifyAlarmScreen(
                                  arg: ModifyAlarmScreenArg(alarm, index),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                )
            ],
          );
        },
      ),
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
  }) : super(key: key);

  final AlarmDataModel alarm;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).chain(CurveTween(curve: Curves.elasticInOut)),
      ),
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
                        .map((weekday) => fromWeekdayToStringShort(weekday))
                        .join(', '),
            style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.cancel),
            color: Colors.red,
            onPressed: () async {
              if (onDelete != null) onDelete!();
            },
          ),
          onTap: onTap,
        ),
      ),
    );
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

