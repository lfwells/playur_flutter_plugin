import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/experiment.dart';
import 'package:playur_flutter_plugin/playur_plugin/login.dart';
import 'package:playur_flutter_plugin/playur_plugin/provider.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

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
              children: const <Widget>[
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

