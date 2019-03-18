import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:media_notification/media_notification.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Watch();
  }
}

class Watch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WatchState();
  }
}

class WatchState extends State<Watch> {
  String status = 'hidden';

  @override
  void initState() {
    super.initState();

    MediaNotification.setListener('pause', () {
      setState(() => stopWatch());
    });

    MediaNotification.setListener('play', () {
      setState(() => startWatch());
    });

    MediaNotification.setListener('next', () {});

    MediaNotification.setListener('prev', () {});

    MediaNotification.setListener('select', () {});
  }

  Future<void> hide() async {
    try {
      await MediaNotification.hide();
      setState(() => status = 'hidden');
    } on PlatformException {}
  }

  Future<void> show(title, author) async {
    try {
      await MediaNotification.show(title: title, author: author);
      setState(() => status = 'play');
    } on PlatformException {}
  }

  BuildContext _scaffoldContext;

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  final _chartSize = const Size(250.0, 250.0);

  Color labelColor = Colors.blue;

  List<CircularStackEntry> _generateChartData(int min, int second) {
    double adjustedSeconds = second * 1.67;
    double adjustedMinutes = min * 1.67;

    Color dialColor = Colors.blue;

    labelColor = dialColor;

    if (second > 0 && second <= 15) {
      dialColor = Colors.deepOrangeAccent;
    } else if (second > 15 && second <= 30) {
      dialColor = Colors.yellow;
    } else if (second > 30 && second <= 45) {
      dialColor = Colors.pinkAccent;
    } else {
      dialColor = Colors.tealAccent;
    }
    Color minuteDialColor;
    if (min % 2 == 0) {
      minuteDialColor = Colors.green;
    } else {
      minuteDialColor = Colors.purple;
    }
    /*
    if (min / 2 == 1) {
      showErrorMessage();
    }
    */
    List<CircularStackEntry> data = [
      CircularStackEntry([new CircularSegmentEntry(adjustedSeconds, dialColor)])
    ];

    if (min > 0) {
      labelColor = Colors.green;
      data.removeAt(0);
      data.add(CircularStackEntry(
          [new CircularSegmentEntry(adjustedSeconds, dialColor)]));

      data.add(CircularStackEntry(
          [new CircularSegmentEntry(adjustedMinutes, minuteDialColor)]));
    }
    return data;
  }

  Stopwatch watch = new Stopwatch();
  Timer timer;

  String elapsedTime = '';

  updateTime(Timer timer) {
    if (watch.isRunning) {
      var milliseconds = watch.elapsedMilliseconds;
      int hundreds = (milliseconds / 10).truncate();
      int seconds = (hundreds / 100).truncate();
      int minutes = (seconds / 60).truncate();

      setState(() {
        elapsedTime = transformMilliseconds(watch.elapsedMilliseconds);
        if (seconds > 59) {
          seconds = seconds - (minutes * 59);
          seconds = seconds - minutes;
        }

        List<CircularStackEntry> data = _generateChartData(minutes, seconds);
        _chartKey.currentState.updateData(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle _labelStyle = Theme.of(context)
        .textTheme
        .title
        .merge(new TextStyle(color: labelColor));
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Custom Stopwatch"),
              elevation: 15.0,
              centerTitle: true,
            ),
            body: new Builder(
              builder: (BuildContext context) {
                _scaffoldContext = context;
                return new Container(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      new Container(
                        child: new AnimatedCircularChart(
                          key: _chartKey,
                          size: _chartSize,
                          initialChartData: _generateChartData(0, 0),
                          chartType: CircularChartType.Radial,
                          edgeStyle: SegmentEdgeStyle.round,
                          percentageValues: true,
                          holeLabel: elapsedTime,
                          labelStyle: _labelStyle,
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),
                      new Row(
                        children: <Widget>[
                          SizedBox(
                            width: 65.0,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.green,
                            child: new Icon(Icons.play_arrow),
                            onPressed: () {
                              startWatch();
                              show("Custom StopWatch", "Flutter Framework");
                            },
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.red,
                            child: new Icon(Icons.stop),
                            onPressed: () {
                              stopWatch();
                            },
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          FloatingActionButton(
                            backgroundColor: Colors.blue,
                            child: new Icon(Icons.refresh),
                            onPressed: () {
                              resetWatch();
                            },
                          )
                        ],
                      ),
                      Container(
                        height: 100.0,
                        child: ListView(
                          children: <Widget>[
                            ListTile(
                              leading: Text(elapsedTime),
                              onTap: () {},
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            )));
  }

  startWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), updateTime);
  }

  stopWatch() {
    watch.stop();
    setTime();
  }

  resetWatch() {
    watch.reset();
    setTime();
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliseconds(timeSoFar);
      List<CircularStackEntry> data = _generateChartData(0, 0);
      _chartKey.currentState.updateData(data);
    });
  }

  transformMilliseconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minuteStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return "$minuteStr : $secondsStr : $hundredsStr";
  }

  @override
  void showErrorMessage() {
    Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
      content: new Text('Server error'),
      duration: new Duration(seconds: 1),
    ));
  }
}
