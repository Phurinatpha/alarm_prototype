import 'package:tflite_flutter/tflite_flutter.dart';

Future<String> sleepPredict(hour,minute) async {
  try {
    final interpreter = await Interpreter.fromAsset('assets/model.tflite');
    var wakeUp = (hour*60)+minute;
    var sleep = wakeUp -(8*60);
    // [Age,gender(M=1,F=0),wakeup time,sleep quality]
    var input =[[23,1,wakeUp,sleep,8.0]]; // ... your input data ...
    var output = List.filled(1*1, 0).reshape([1,1]);
    interpreter.run(input, output);
    var result = output.toList().map((list) => list[0]).toList();
    String ans =  sleepFormat(result);
    print(ans);
    return ans;
  } catch (e) {

    print("Error loading model: $e");
  }
 return "";
}

String sleepFormat(x){
  var data = x[0] ;
  String hour =  (data~/60).toString();
  String minute = ((data%60).round()).toString();
  if (hour.length < 2 ) { hour = "0"+ hour ;}
  if (minute.length <2) { minute = "0" + minute ;}
  String item = hour + ":" + minute ;


  return item;
}