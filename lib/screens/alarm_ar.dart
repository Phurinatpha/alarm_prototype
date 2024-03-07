import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityDemoScreen extends StatefulWidget {
  const UnityDemoScreen({Key? key}) : super(key: key);

  @override
  State<UnityDemoScreen> createState() => _UnityDemoScreenState();
}

class _UnityDemoScreenState extends State<UnityDemoScreen> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  UnityWidgetController? _unityWidgetController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        bottom: false,
        child: WillPopScope(
          onWillPop: () async {
            // Pop the category page if Android back button is pressed.
            return true;
          },
          child: Container(
            // color: Colors.yellow,
            child: UnityWidget(
              onUnityCreated: onUnityCreated,
            ),
          ),
        ),
      ),
    );
  }

  void onUnityMessage(message) {
    print('+++++++++++++++++++++++++++++++++Received message from unity: ${message.toString()}');
    if (message == "close") {
      // Unload the Unity player
      _unloadUnityPlayer();
    }
  }

  void _unloadUnityPlayer() {
    // Add code to unload the Unity player here
    // For example, you can use Navigator.pop to go back
    Navigator.pop(context);
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
  }
}