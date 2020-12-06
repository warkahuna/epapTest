import 'dart:convert';
import 'dart:math';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:epapTest/model/Alarm.dart';
import 'package:epapTest/ui/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewAlarm extends StatefulWidget {
  @override
  _NewAlarmState createState() => _NewAlarmState();
}

class _NewAlarmState extends State<NewAlarm> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  TextEditingController contentController;
  TextEditingController chosenTimeController;
  TextEditingController chosenIntervalController;
  GlobalKey<ScaffoldState> _scaffoldKey;
  var _intervals = [
    "minute",
    "hour",
    "day",
    "week",
  ];
  var _selected = -1;

  void initState() {
    super.initState();
    contentController = new TextEditingController();
    chosenTimeController = new TextEditingController();
    chosenIntervalController = new TextEditingController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    initializeNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Color(0xFF3EB16F),
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.lightBlue[300],
              onPressed: () {
                Route route =
                    MaterialPageRoute(builder: (context) => HomePage());
                Navigator.pushReplacement(context, route);
              }),
          centerTitle: true,
          title: Text(
            "Add New Alarm",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
            ),
          ),
          elevation: 0.0,
        ),
        body: Container(
          child: Column(children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width / 1.1,
              child: _entryField("Alarm text", contentController),
            ),
            _intervalSelector(),
            _showChosenTime(),
            _dateTime(),
            _addAlarm()
          ]),
        ));
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PanelTitle(
            isRequired: true,
            title: "Alarm Message",
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _dateTime() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            color: Colors.lightBlue[300],
            onPressed: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2018, 3, 5),
                  maxTime: DateTime(2019, 6, 7), onChanged: (date) {
                print('change $date');
              }, onConfirm: (date) {
                print('confirm $date');
                chosenTimeController.text = date.toString();
                setState(() {});
              }, currentTime: DateTime.now());
            },
            child: Text(
              'Starting time',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addAlarm() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          RaisedButton(
            color: Colors.lightBlue[300],
            onPressed: () {
              saveAlarmAndSetNotif();
            },
            child: Text(
              'Save alarm',
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showChosenTime() {
    String chosenTime = "";

    if (chosenTimeController.text == "") {
      chosenTime = "please chose a starting time";
    } else {
      chosenTime = "time chosen: " + chosenTimeController.text;
      print("state");
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          PanelTitle(
            isRequired: true,
            title: chosenTime,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget _intervalSelector() {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Remind me every  ",
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            DropdownButton<int>(
              iconEnabledColor: Colors.lightBlue[300],
              hint: _selected == -1
                  ? Text(
                      "Select an Interval",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w400),
                    )
                  : null,
              elevation: 4,
              value: _selected == -1 ? null : _selected,
              items: _intervals.map((String value) {
                return DropdownMenuItem<int>(
                  value: _intervals.indexOf(value),
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _selected = newVal;
                  chosenIntervalController.text = _intervals[_selected];
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void displayError(String error) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(error),
        duration: Duration(milliseconds: 2000),
      ),
    );
  }

  int makeIDs() {
    Random random = new Random();
    int randomNumber = random.nextInt(100);
    return randomNumber;
  }

  initializeNotifications() async {
    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: onSelectNotification);
    } catch (e) {
      print(e);
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  static void printHello(int alarmID) async {
    print("alarm id");
    print(alarmID);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('alarms');

    List alarms;
    alarms = jsonDecode(stringValue);
    print(alarms);
    var alarm = jsonDecode(alarms[alarms.length - 1]);
    print(alarm["id"]);
    RepeatInterval interval;
    if (alarm["interval"] == "hour") {
      interval = RepeatInterval.hourly;
    } else if (alarm["interval"] == "day") {
      interval = RepeatInterval.daily;
    } else if (alarm["interval"] == "week") {
      interval = RepeatInterval.weekly;
    } else if (alarm["interval"] == "minute") {
      interval = RepeatInterval.everyMinute;
    }

    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      print(e);
    }

    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID ' + alarmID.toString(),
      'CHANNEL_NAME ' + alarmID.toString(),
      "CHANNEL_DESCRIPTION " + alarmID.toString(),
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      alarmID,
      'Reminder',
      alarm["content"],
      interval,
      platformChannelSpecifics,
      payload: alarmID.toString(),
    );
  }

  Future<void> saveData(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List alarms = new List<dynamic>();
    alarms = await getData();
    print("list alarms");
    print(alarms);

    print("adding new alarm");
    Alarm alarm = new Alarm(
        content: contentController.text,
        interval: chosenIntervalController.text,
        startTime: chosenTimeController.text,
        notificationID: id.toString(),
        active: true);

    alarms.add(jsonEncode(alarm.toJson()));
    print(alarms.toString());
    prefs.setString('alarms', jsonEncode(alarms));
  }

  Future<List> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('alarms');
    print(stringValue);
    List alarms;
    if (stringValue != null) {
      alarms = jsonDecode(stringValue);
      return alarms;
    } else {
      return [];
    }
  }

  List<int> setTime() {
    List<int> time = new List<int>();
    var duration = DateTime.parse(chosenTimeController.text);
    var difference = duration.difference(DateTime.now());

    var d = (difference.inSeconds / (3600 * 24));
    var h = (difference.inSeconds % (3600 * 24) / 3600);
    var m = (difference.inSeconds % 3600 / 60);
    var s = (difference.inSeconds % 60);
    time.add(d.floor());
    time.add(h.floor());
    time.add(m.floor());
    time.add(s.floor());
    return time;
  }

  void saveAlarmAndSetNotif() async {
    final int alarmID = Random().nextInt(pow(2, 31));
    saveData(alarmID);
    List<int> time = setTime();
    var alamWork;
    await AndroidAlarmManager.initialize();
    try {
      alamWork = await AndroidAlarmManager.oneShot(
          Duration(
              days: time[0],
              hours: time[1],
              minutes: time[2],
              seconds: time[3]),
          alarmID,
          printHello);
    } catch (e) {
      print(e);
    }
    if (alamWork) {
      AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          headerAnimationLoop: false,
          animType: AnimType.TOPSLIDE,
          title: 'Succes',
          desc: 'Alarm saved',
          btnOkOnPress: () {})
        ..show();
    }
  }
}

class PanelTitle extends StatelessWidget {
  final String title;
  final bool isRequired;
  PanelTitle({
    Key key,
    @required this.title,
    @required this.isRequired,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Text.rich(
        TextSpan(children: <TextSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500),
          ),
          TextSpan(
            text: isRequired ? " *" : "",
            style: TextStyle(fontSize: 14, color: Colors.lightBlue[300]),
          ),
        ]),
      ),
    );
  }
}
