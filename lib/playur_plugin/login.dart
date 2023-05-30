import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/log.dart';
import 'package:playur_flutter_plugin/playur_plugin/provider.dart';
import 'package:provider/provider.dart';

class PlayURLoginScreen extends StatefulWidget {
  const PlayURLoginScreen({Key? key}) : super(key: key);

  @override
  State<PlayURLoginScreen> createState() => _PlayURLoginScreenState();
}

class _PlayURLoginScreenState extends State<PlayURLoginScreen>
{
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  String feedback = "";

  @override
  Widget build(BuildContext context) {

    try
    {
      Provider.of<PlayURProvider>(context, listen: false);
    }
    catch (e)
    {
      return ErrorWidget("PlayURProvider not found");
    }

    return Column(children: [
      TextFormField(
        controller: usernameController,
        decoration: const InputDecoration(
          labelText: 'Username',
        ),
      ),
      TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
        ),
      ),
      ElevatedButton(
        onPressed: _login,
        child: const Text('Login'),
      ),
      Text(feedback),
    ],);
  }

  Future _login() async
  {
    var provider = Provider.of<PlayURProvider>(context, listen: false);

    setState(() {
      feedback = "Logging in... ";
    });

    // TODO: return login
    /*
    if (ENABLE_PERSISTENCE)
    {
      UnityEngine.PlayerPrefs.SetString(PlayURPlugin.PERSIST_KEY_PREFIX + "username", username.text);
    }*/

    var result = await provider.login(context, usernameController.text, passwordController.text);
    passwordController.clear();

    PlayURPluginLogger.log("Login Success: ${result.success}");
    if (result.success == false)
      {
        setState(() {
          feedback = "Login failed: ${result.result["message"]}";
        });
      }
  }
}
