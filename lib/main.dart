import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/src/widgets/framework.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isOn = false;
  bool isNear = false;
  String path = 'img/demogorgon.jpg';
  late StreamSubscription<dynamic> streamSubscription;

  @override
  void initState() {
    super.initState();
    listenSensor();
  }

  @override
  void dispose() {
    super.dispose();
    streamSubscription.cancel();
  }

  Future<void> listenSensor() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (foundation.kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    streamSubscription = ProximitySensor.events.listen((int event) {
      setState(() {
        isNear = (event > 0) ? true : false;
        if (isNear == true) {
          _torchLight();
          _vibrate();
          path = 'img/eleven.jpg';
        } else {
          _torchLight();
          path = 'img/demogorgon.jpg';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              path,
              width: 300,
              height: 300,
              alignment: Alignment.center,
            ),
            Text('Está próximo do sensor: $isNear')
          ],
        ),
      ),
    );
  }

  Future<void> _torchLight() async {
    if (!isOn) {
      isOn = true;
      try {
        await TorchLight.disableTorch();
      } on Exception catch (_) {
        print('error disabling torch light');
      }
    } else {
      isOn = false;
      try {
        await TorchLight.enableTorch();
      } on Exception catch (_) {
        print('error enabling torch light');
      }
    }
  }

  Future<void> _vibrate() async {
    Vibration.vibrate(duration: 1500, amplitude: 128);
  }
}
