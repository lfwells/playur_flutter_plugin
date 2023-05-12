import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/api.dart';
import 'package:playur_flutter_plugin/playur_plugin/classes/configuration.dart';
import 'package:playur_flutter_plugin/playur_plugin/classes/user.dart';
import 'package:playur_flutter_plugin/playur_plugin/log.dart';

class PlayURProvider extends ChangeNotifier
{
  final int gameID;
  final String clientSecret;

  bool loggedIn = false;
  bool experimentFull = false;
  bool hasConfiguration = false;

  late PlayURConfiguration configuration;
  late PlayURUser user;

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
    if (result.success)
    {
      user = PlayURUser();
      user.name = username;
      user.id = int.tryParse(result.result["id"])!;

      loggedIn = true;

      //TODO: other on-login callbacks
      /*
      PlayerPrefs.Load(callback);
      StartCoroutine(PlayerPrefs.PeriodicallySavePlayerPrefs());
      */
      _configuration();

      notifyListeners();
    }
    return result;
  }

  // TODO: implement configuration
  Future _configuration() async
  {
    PlayURPluginLogger.log("Getting Configuration...");
    var form = PlayURAPI.getWWWFormWithProvider(this);

    experimentFull = false;

    //TODO: enums
    //Experiment? experiment = null;

    // TODO: experiment loading from some other source
    /*
    bool experimentOverrideFound = false;
    //try and get an experiment from the experiment URL
    if (didRequestExperiment)
    {
      experimentOverrideFound = true;
      experiment = requestedExperiment;
    }
    #if (UNITY_ANDROID || UNITY_IOS)  && !UNITY_EDITOR
  if (experimentOverrideFound == false && PlayURPluginHelper.instance != null)
  {
  experimentOverrideFound = PlayURPluginHelper.instance.useSpecificExperimentForMobileBuild;
  experiment = PlayURPluginHelper.instance.mobileExperiment;
  }
  #elif UNITY_STANDALONE && !UNITY_EDITOR
  if (experimentOverrideFound == false && PlayURPluginHelper.instance != null)
  {
  experimentOverrideFound = PlayURPluginHelper.instance.useSpecificExperimentForDesktopBuild;
  experiment = PlayURPluginHelper.instance.desktopExperiment;
  }
  #endif
  //if not found, try and get an experiment from the PluginHelper script
  if (Application.isEditor && experimentOverrideFound == false && PlayURPluginHelper.instance != null)
  {
  experimentOverrideFound = PlayURPluginHelper.instance.forceToUseSpecificExperiment;
  experiment = PlayURPluginHelper.instance.experimentToTestInEditor;
  }
  if (experimentOverrideFound && experiment.HasValue)
  {
  form.Add("experimentID", ((int)experiment.Value).ToString());
  Log("Using Experiment Override "+experiment.Value.ToString());
  }

    bool experimentGroupOverrideFound = false;
    ExperimentGroup? experimentGroup = null;
    if (didRequestExperimentGroup)
    {
    experimentGroupOverrideFound = true;
    experimentGroup = requestedExperimentGroup;
    }
    //if not found, try and get an experiment group from the PluginHelper script
    if (Application.isEditor && experimentGroupOverrideFound == false && PlayURPluginHelper.instance != null)
    {
    experimentGroupOverrideFound = PlayURPluginHelper.instance.forceToUseSpecificGroup;
    experimentGroup = PlayURPluginHelper.instance.groupToTestInEditor;
    }
    if (experimentGroupOverrideFound && experimentGroup.HasValue)
    {
    form.Add("experimentGroupID", ((int)experimentGroup.Value).ToString());
    Log("Using Experiment Group Override "+experimentGroup.Value.ToString());
    }
*/

    //go ahead and get config now
    var result = await PlayURAPI.get("Configuration", form, debugOutput: true);

    if (result.success)
    {
      configuration = PlayURConfiguration();

      configuration.experimentID = int.tryParse(result.result["experiment"]["id"])!;
      configuration.experimentGroupID = int.tryParse(result.result["group"]["id"])!;

      configuration.branch = result.result["branch"];
      configuration.buildID = int.tryParse(result.result["buildID"])!;

      //TODO: enums
      /*
      configuration.experiment = (Experiment)configuration.experimentID;
      configuration.experimentGroup = (ExperimentGroup)configuration.experimentGroupID;
       */

      //TODO: enums
      /*
      var elements = result["elements"];



      configuration.elements = new List<Element>();
      foreach (var element in elements)
      {
      configuration.elements.Add((Element)element.Value["id"].AsInt);
      }*/

      var parameters = result.result["parameters"];
      configuration.parameters = json.decode(json.encode(parameters)) as Map<String, dynamic>;

      //TODO: enums
      /*
      configuration.analyticsColumnsOrder = new List<AnalyticsColumn>();
      var inColumns = new List<JSONNode>();
      foreach (var column in result["analyticsColumns"])
      {
      inColumns.Add(column.Value);
      }
      inColumns.Sort((a,b) =>
      {
      if (a["sort"].AsInt == b["sort"].AsInt)
      {
      return a["id"].AsInt.CompareTo(b["id"].AsInt);
      }
      return a["sort"].AsInt.CompareTo(b["sort"].AsInt);
      });
      foreach (var column in inColumns)
      {
      var columnAsEnum = (AnalyticsColumn)(column["id"].AsInt);
      configuration.analyticsColumnsOrder.Add(columnAsEnum);
      }*/

      //TODO: user class
      /*
      if (result.result["accessLevel"] != null)
      {
        user.accessLevel = result.result["accessLevel"].AsInt;
      }*/

      hasConfiguration = true;
    }
    else
    {
      PlayURPluginLogger.error(result.result["message"]);

      if (result.result["closed"] != null && result.result["closed"] is bool && result.result["closed"] as bool == true)
      {
        PlayURPluginLogger.error("No experiment group left with enough spots to allocate user! Check max members setting on experiment group. This error can also occur if you don't have any Experiment Groups configured for an Experiment.");
        experimentFull = true;
      }
      hasConfiguration = false;
    }

    notifyListeners();
  }


}