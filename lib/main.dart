import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:workmanager/workmanager.dart';
import 'database.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp( MyApp());
}

 void callbackDispatcher() {
  print("callbackDispatcher");
  try{
    print("inside try of callbackDispatcher");
    Workmanager().executeTask((task, inputData) async {
      await sendErrorEmail();
      return true;
      // print("inputData $inputData");
      // if (task == 'sendErrorEmailTask') {
      //   final scheduledTime = inputData!['scheduledTime'];
      //   final now = DateTime.now();
      //   final scheduledDate = DateTime(now.year, now.month, now.day, int.parse(scheduledTime.split(':')[0]), int.parse(scheduledTime.split(':')[1]));
      //   if (now.isBefore(scheduledDate)) {
      //     return Future.value(false);
      //   }
      //   sendErrorEmail();
      // }
      // return Future.value(true);
    });
  } catch(e){
    print(e);
  }

}

Future<void> sendErrorEmail() async {
  print("here");
  try{
    final errorTransactions = await DatabaseHelper.instance.getErrorTransactions();
    if (errorTransactions.isNotEmpty) {
      final mailOptions = MailOptions(
        body: 'The following transactions have errors: ${errorTransactions.toString()}',
        subject: 'Error Transactions Report',
        recipients: ['harishyogan123@gmail.com'],
      );
      print(mailOptions);
      await FlutterMailer.send(mailOptions);
    }else{
      print("empty");
    }
  } catch(e){
    print(e);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    callQuery();
    Workmanager().registerPeriodicTask(
      "sendErrorEmail",
      "sendErrorEmailTask",
      frequency: Duration(minutes: 15),
      initialDelay: Duration(minutes: 5),
    );
  }

  callQuery() async {
    final db = DatabaseHelper.instance;
    final allRows = await db.getErrorTransactions();
    print("all rows $allRows");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        body: Container(),
      ),
    );
  }
}