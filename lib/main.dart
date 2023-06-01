import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/experiment.dart';
import 'package:playur_flutter_plugin/playur_plugin/login.dart';
import 'package:playur_flutter_plugin/playur_plugin/provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy(); //TODO: can I call this from anywhere?
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

@js.JSExport()
class PlayURSample extends StatefulWidget {
  const PlayURSample({Key? key}) : super(key: key);

  @override
  State<PlayURSample> createState() => _PlayURSampleState();
}

class _PlayURSampleState extends State<PlayURSample>
{
  bool initializing = true;
  String? username;
  String? password;

  @override
  void initState()
  {
    super.initState();
    final export = js_util.createDartExport(this);
    js_util.setProperty(js_util.globalThis, '_appState', export);
    js_util.callMethod<void>(js_util.globalThis, '_stateSet', []);

    //if (!kDebugMode)
    {
      //loggingIn = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build $initializing");
    if (initializing)
    {
      return Container(
        color: Colors.blueGrey,
        child: const Center(child:CircularProgressIndicator(color: Colors.white)));
    }
    return ChangeNotifierProvider(create: (context) {
        var model = PlayURProvider(context);
      if (username != null && password != null) {
          model.login(context, username!, password!);
        }
        return model;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PlayUR Sample'),
        ),
        body: Consumer<PlayURProvider>(
          builder: (context, playUR, child) {
            if (playUR.loggingIn) {
              return const Center(child: CircularProgressIndicator());
            }
            if (playUR.loggedIn == false) {
              return const PlayURLoginScreen();
            }
            return child!;
          },
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PlayURExperimentTest(),
                PlayURParameterText(parameter: "MessageToUser",),
                PlayURRandomParameterSample(parameter: "Test"),
              ],
            ),
          )
        ),
      ),
    );
  }

  @js.JSExport()
  void login(String username, String password) {
    setState(() {
      initializing = false;
      this.username = username;
      this.password = password;
    });
  }
}

class PlayURExperimentTest extends StatelessWidget {
  const PlayURExperimentTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayURProvider>(
      builder: (context, playUR, _) {
        if (!playUR.hasConfiguration) return const Text("loading");
        return Text("Experiment: ${playUR.configuration.experiment} ${playUR.configuration.experiment.name}\n check: ${playUR.configuration.experiment == Experiment.TestExperiment}");
      }
    );
  }
}


class PlayURRandomParameterSample extends StatefulWidget {
  const PlayURRandomParameterSample({
    Key? key, required this.parameter, this.notReadyWidget,
  }) : super(key: key);

  final String parameter;
  final Widget? notReadyWidget;

  @override
  State<PlayURRandomParameterSample> createState() => _PlayURRandomParameterSampleState();
}

class _PlayURRandomParameterSampleState extends State<PlayURRandomParameterSample>
{
  String current = "loading";

  @override
  void initState() {
    super.initState();
    next();
  }

  Future next() async
  {
    var playUR = Provider.of<PlayURProvider>(context, listen: false);
    await playUR.waitForConfiguration();

    var list = playUR.getStringParamList(widget.parameter);
    setState(() {
      //set current to a random item from list
      current = list[math.Random().nextInt(list.length)];
    });

  }

  @override
  Widget build(BuildContext context)
  {
    return Consumer<PlayURProvider>(
      builder: (context, playUR, _)
      {
        if (!playUR.hasConfiguration) return widget.notReadyWidget ?? Container();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: next, child: const Text("Next Random Val")),
            Container(width:8),
            Text(current),
          ],
        );
      }
    );
  }
}

class PlayURParameterText extends StatelessWidget {
  const PlayURParameterText({
    Key? key, required this.parameter, this.notReadyWidget,
  }) : super(key: key);

  final String parameter;
  final Widget? notReadyWidget;

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayURProvider>(
      builder: (context, playUR, _) {
        if (!playUR.hasConfiguration) return notReadyWidget ?? Container();
        return Text(playUR.getStringParam(parameter));
      },
    );
  }
}

