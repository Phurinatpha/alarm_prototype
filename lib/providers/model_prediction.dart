import 'package:tflite_flutter/tflite_flutter.dart';

///ฟังก์ชันdata model ที่ใช้ prediction เวลาการนอนหลับ
Future<String> sleepPredict(hour, minute) async {
  ///โหลดโมเดลtensorflowlite
  try {
    final interpreter = await Interpreter.fromAsset('assets/model.tflite');
    var wakeUp = (hour * 60) + minute;
    var sleep = wakeUp - (8 * 60);
    // [Age,gender(M=1,F=0),wakeup time,sleep quality]
    var input = [
      [23, 1, wakeUp, sleep, 8.0]
    ]; // input data
    ///แสดงoutputของข้อมูลที่ถูกทํานาย
    var output = List.filled(1 * 1, 0).reshape([1, 1]);
    interpreter.run(input, output);
    var result = output.toList().map((list) => list[0]).toList();
    String ans = sleepFormat(result);
    print(ans);
    return ans;
  } catch (e) {
    print("Error loading model: $e");
  }
  return "";
}

///ฟังก์ชันsleepFormat ทําการแปลงข้อมูลจากการทํานายให้เป็นข้อมูลเวลาที่อ่านง่าย
String sleepFormat(x) {
  var data = x[0];
  String hour = (data ~/ 60).toString();
  String minute = ((data % 60).round()).toString();
  if (hour.length < 2) {
    hour = "0" + hour;
  }
  if (minute.length < 2) {
    minute = "0" + minute;
  }
  String item = hour + ":" + minute;

  return item;
}

///ฟังก์ชันwakeupFormat ทําการแปลงข้อมูลจากชั่วโมงและนาทีให้กลายเป็นเวลา(ชั่วโมง:นาที)
String wakeupFormat(x, y) {
  String hour = x.toString();
  String minute = y.toString();
  if (hour.length < 2) {
    hour = "0" + hour;
  }
  if (minute.length < 2) {
    minute = "0" + minute;
  }
  String item = hour + ":" + minute;

  return item;
}
