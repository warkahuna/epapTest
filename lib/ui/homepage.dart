import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:epapTest/model/Alarm.dart';
import 'package:epapTest/ui/newalarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List alarms;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  void initState() {
    super.initState();
    getData();
    print("setCall");
    print(alarms);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
  }

  initializeNotifications() async {
    try {
      var initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettingsIOS = IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[300],
        elevation: 0.0,
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              color: Colors.grey[800],
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.WARNING,
                  headerAnimationLoop: false,
                  animType: AnimType.TOPSLIDE,
                  title: 'Warning',
                  desc: 'All your alarms will be deleted',
                  btnCancelOnPress: () {},
                  btnOkOnPress: () {
                    _deleteAllAlarm();
                  },
                )..show();
              }),
        ],
      ),
      body: Container(
        color: Color(0xFFF6F8FC),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 3,
              child: TopContainer(),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              flex: 7,
              child: _alarms(),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: Colors.lightBlue[300],
        child: Icon(
          Icons.add,
          color: Colors.grey[800],
        ),
        onPressed: () {
          Route route = MaterialPageRoute(builder: (context) => NewAlarm());
          Navigator.pushReplacement(context, route);

          /*Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewAlarm(),
            ),
          );*/
        },
      ),
    );
  }

  Widget _alarms() {
    if (alarms.length > 0) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: GridView.builder(
            itemCount: alarms.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      side: BorderSide(width: 2, color: Colors.lightBlue[300])),
                  elevation: 5.0,
                  child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.topLeft,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Content: ' +
                                      jsonDecode(alarms[index])['content'],
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Interval: ' +
                                      jsonDecode(alarms[index])['interval'],
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Started: ' +
                                      jsonDecode(alarms[index])['start'],
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: jsonDecode(alarms[index])['active']
                                    ? Text(
                                        'Activated: tap to change',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      )
                                    : Text(
                                        'Desactivated:' +
                                            "\n" +
                                            'tap to change',
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                onTap: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    child: new CupertinoAlertDialog(
                      title: new Column(
                        children: <Widget>[
                          jsonDecode(alarms[index])['active']
                              ? new Text("alarm status: activated")
                              : new Text("alarm status: desactivated"),
                          new Icon(
                            Icons.alarm,
                            color: Colors.lightBlue[300],
                          ),
                        ],
                      ),
                      content: new Text("the status of alarm will change "),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              _cancelAndActivateNotification(
                                jsonDecode(alarms[index])['id'],
                              );
                              getData();
                            },
                            child: new Text("OK")),
                        FlatButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              _deleteNotification(
                                jsonDecode(alarms[index])['id'],
                              );
                            },
                            child: new Text("Delete"))
                      ],
                    ),
                  );
                },
              );
            }),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'you don\'t have any alarms yet',
          style: TextStyle(
            color: Colors.grey[800],
          ),
        ),
      );
    }
  }

  void getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('alarms');

    if (stringValue != null) {
      alarms = jsonDecode(stringValue);
    } else {
      alarms = [];
    }
    print(alarms);
    setState(() {});
  }

  Future<void> _cancelAndActivateNotification(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Alarm alarm;
    print("notification modification");
    print(alarms);
    var modifiedAlarm;
    for (var item in alarms) {
      if (jsonDecode(item)["id"] == id) {
        if (jsonDecode(item)["active"]) {
          alarm = new Alarm(
            notificationID: id,
            startTime: jsonDecode(item)["start"],
            active: false,
            content: jsonDecode(item)["content"],
            interval: jsonDecode(item)["interval"],
          );
          try {
            print("notification cancel: " + id);
            await flutterLocalNotificationsPlugin.cancel(int.parse(id));
          } catch (e) {
            print(e);
          }
        } else {
          alarm = new Alarm(
            notificationID: id,
            startTime: jsonDecode(item)["start"],
            active: true,
            content: jsonDecode(item)["content"],
            interval: jsonDecode(item)["interval"],
          );
          RepeatInterval interval;
          if (jsonDecode(item)["interval"] == "hour") {
            interval = RepeatInterval.hourly;
          } else if (jsonDecode(item)["interval"] == "day") {
            interval = RepeatInterval.daily;
          } else if (jsonDecode(item)["interval"] == "week") {
            interval = RepeatInterval.weekly;
          } else if (jsonDecode(item)["interval"] == "minute") {
            interval = RepeatInterval.everyMinute;
          }
          print("notification continue: " + id);
          _scheduleNotification(id, jsonDecode(item)["content"], interval);
        }
        print(jsonEncode(alarm.toJson()));
        modifiedAlarm = alarms.indexOf(item);
      }
    }
    alarms.removeAt(modifiedAlarm);
    alarms.insert(modifiedAlarm, jsonEncode(alarm.toJson()));
    print(alarms);
    prefs.setString('alarms', jsonEncode(alarms));
  }

  Future<void> _deleteNotification(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Alarm alarm;
    var modifiedAlarm;
    for (var item in alarms) {
      if (jsonDecode(item)["id"] == id) {
        try {
          print("notification deleted: " + id);
          await flutterLocalNotificationsPlugin.cancel(int.parse(id));
        } catch (e) {
          print(e);
        }
        modifiedAlarm = alarms.indexOf(item);
      }
    }

    alarms.removeAt(modifiedAlarm);
    print(alarms);
    if (alarm == null) {
      print("delete all");
      await prefs.clear();
    } else {
      prefs.setString('alarms', jsonEncode(alarms));
    }

    getData();
  }

  Future<void> _deleteAllAlarm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await flutterLocalNotificationsPlugin.cancelAll();
    getData();
  }

  Future<void> _scheduleNotification(
      id, content, RepeatInterval interval) async {
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID ' + id.toString(),
      'CHANNEL_NAME ' + id.toString(),
      "CHANNEL_DESCRIPTION " + id.toString(),
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidChannelSpecifics, iOS: iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(
      int.parse(id),
      'Reminder',
      content,
      interval,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }
}

class TopContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(50, 27),
          bottomRight: Radius.elliptical(50, 27),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.grey[400],
            offset: Offset(0, 3.5),
          )
        ],
        color: Colors.lightBlue[300],
      ),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              "EPAP",
              style: TextStyle(
                fontFamily: "YeonSung",
                fontSize: 64,
                color: Colors.grey[800],
              ),
            ),
          ),
          Divider(
            color: Color(0xFFB0F3CB),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Center(
              child: Text(
                "Alarms",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          Icon(
            Icons.arrow_downward,
            color: Colors.grey[800],
          ),
        ],
      ),
    );
  }
}

class BottomContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.elliptical(50, 27),
          topRight: Radius.elliptical(50, 27),
          bottomLeft: Radius.elliptical(50, 27),
          bottomRight: Radius.elliptical(50, 27),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            color: Colors.grey[400],
            offset: Offset(0, 3.5),
          )
        ],
        color: Colors.grey[350],
      ),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              bottom: 10,
            ),
            child: Text(
              "Reminders",
              style: TextStyle(
                fontFamily: "Angel",
                fontSize: 64,
                color: Colors.white,
              ),
            ),
          ),
          Divider(
            color: Color(0xFFB0F3CB),
          ),
        ],
      ),
    );
  }
}
