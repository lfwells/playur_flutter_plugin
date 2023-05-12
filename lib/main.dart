import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/login.dart';
import 'package:playur_flutter_plugin/playur_plugin/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlayURSample()
    );
  }
}

class PlayURSample extends StatelessWidget {
  const PlayURSample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => PlayURProvider(context, gameID: 20, clientSecret: "dunno"),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PlayUR Sample'),
        ),
        body: Consumer<PlayURProvider>(
          builder: (context, playUR, child) {
            if (playUR.loggedIn == false) {
              return const PlayURLoginScreen();
            }
            return child!;
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Consumer<PlayURProvider>(
                  builder: (context, playUR, _) {
                    return Text(playUR.getStringParam("MessageToUser"));
                  },
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}

