import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/api.dart';
import 'package:playur_flutter_plugin/playur_plugin/configuration.dart';

class PlayURProvider extends ChangeNotifier
{
  final int gameID;
  final String clientSecret;

  bool loggedIn = false;
  bool experimentFull = false;
  bool hasConfiguration = false;

  late PlayURConfiguration configuration;

  PlayURProvider(BuildContext context, { required this.gameID, required this.clientSecret })
  {
    // TODO: use a rest queue
    // StartCoroutine(Rest.Queue.StartProcessing());

    // TODO: return login
    //login(username, password, returnLogin: true);

    // TODO: logic for experiment being full (move to GetConfiguration)
    /*
    if (experimentFull)
    {
      if (PlayURLoginCanvas.exists) PlayURLoginCanvas.instance.CancelLogin();
      SceneManager.LoadScene("PlayURLogin");
      yield return new WaitForEndOfFrame();
      PlayURLoginCanvas.instance.ShowError("Experiment has closed, please check with game owner for more details.");
      throw new ExperimentGroupsFullException(user, gameID);
    }
    */
  }

  // TODO: implement login
  Future<ServerCallback> login(BuildContext context, String username, String password, { bool returnLogin = false }) async
  {
    var form = PlayURAPI.getWWWForm(context);
    form["username"] = username;
    form["password"] = password;

    var result = await PlayURAPI.post("Login", form, debugOutput: true);
    if (result.success) {
      //TODO: implement user object
      /*
        user = new User();
        user.name = username;
        user.id = result["id"];
      */
      loggedIn = true;

      //TODO: other on-login callbacks
      /*
      PlayerPrefs.Load(callback);
      StartCoroutine(PlayerPrefs.PeriodicallySavePlayerPrefs());
      _configuration();
      */

      notifyListeners();
    }
    return result;
  }

  // TODO: implement configuration
  Future _configuration() async
  {
    await Future.delayed(Duration(seconds: 5));
    hasConfiguration = true;
    configuration = PlayURConfiguration();
    notifyListeners();
  }


}