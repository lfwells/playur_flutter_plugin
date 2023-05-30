import 'dart:convert';
import 'package:playur_flutter_plugin/playur_plugin/generated/token.dart';

import 'package:flutter/material.dart';
import 'package:playur_flutter_plugin/playur_plugin/api.dart';
import 'package:playur_flutter_plugin/playur_plugin/classes/configuration.dart';
import 'package:playur_flutter_plugin/playur_plugin/classes/user.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/analytics_column.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/experiment.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/experiment_group.dart';
import 'package:playur_flutter_plugin/playur_plugin/generated/element.dart' as e;
import 'package:playur_flutter_plugin/playur_plugin/log.dart';

class PlayURProvider extends ChangeNotifier
{
  late final int gameID;
  late final String clientSecret;

  bool loggedIn = false;
  bool experimentFull = false;
  bool hasConfiguration = false;

  late PlayURConfiguration configuration;
  late PlayURUser user;

  PlayURProvider(BuildContext context)
  {
    //read in the game id and client secret from token.dart
    gameID = PlayURToken.gameID;
    clientSecret = PlayURToken.clientSecret;

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

      configuration.experiment = Experiment.fromValue(configuration.experimentID);
      configuration.experimentGroup = ExperimentGroup.fromValue(configuration.experimentGroupID);

      var elements = result.result["elements"];
      configuration.elements = [];
      for (var e in elements as List<dynamic>)
      {
        configuration.elements.add(e.Element.fromValue(int.parse(e["id"])));
      }

      var parameters = result.result["parameters"];
      configuration.parameters = json.decode(json.encode(parameters)) as Map<String, dynamic>;

      configuration.analyticsColumnsOrder = [];
      var inColumns = [];
      for (var column in result.result["analyticsColumns"] as List<dynamic>)
      {
        inColumns.add(Map<String, dynamic>.from(column));
      }
      inColumns.sort((a,b)
      {
        int aSort = int.parse(a["sort"]);
        int bSort = int.parse(b["sort"]);
        if (aSort == bSort)
        {
          return int.parse(a["id"]).compareTo(int.parse(b["id"]));
        }
        return aSort.compareTo(bSort);
      });

      for (var column in inColumns)
      {
        var columnAsEnum = AnalyticsColumn.fromValue(int.parse(column["id"]));
        configuration.analyticsColumnsOrder.add(columnAsEnum);
      }

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

  Future waitForLogin() async
  {
    while(!loggedIn)
    {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
  Future waitForConfiguration() async
  {
    await waitForLogin();
    while(!hasConfiguration)
    {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }


  /// <summary>Gets all enabled Game Elements from the current configuration.</summary>
  /// <returns>a list of the active Game Elements.</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if configuration is not previously obtained</exception>
  List<e.Element> listElements()
  {
    if (hasConfiguration == false)
    {
      //TODO: exceptions
      throw Exception("ConfigurationNotReadyException");
      //throw new ConfigurationNotReadyException();
    }
    return configuration.elements;
  }

  /// <summary>Query if a certain element is enabled or not</summary>
  /// <returns>true if the given element is enabled.</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if configuration is not previously obtained</exception>
  bool elementEnabled(e.Element element)
  {
    if (hasConfiguration == false)
    {
      //TODO: exceptions
      throw Exception("ConfigurationNotReadyException");
      //throw new ConfigurationNotReadyException();
    }
    return configuration.elements.contains(element);
  }






  //TODO: docs
  bool paramExists(String key)
  {
    if (!hasConfiguration)
    {
      //TODO: exceptions
      throw Exception("ConfigurationNotReadyException");
      //throw ConfigurationNotReadyException();
    }
    return configuration.parameters.containsKey(key);
  }

  /// <summary>
  /// Obtains a value of a parameter defined in the <see cref="Configuration"/>. This is the base-level function intended to be internal.
  /// All parameters are initially obtained as strings and must be converted to their type.
  /// </summary>
  /// <param name="key">The key matching the parameter name set on the back-end</param>
  /// <returns>The value of the requested parameter if it exists</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if <see cref="Configuration"/> is not previously obtained</exception>
  /// <exception cref="ParameterNotFoundException">thrown if no parameter with that name present in the <see cref="Configuration"/></exception>
  String getParam(String key, { String? defaultValue, bool warn = true })
  {
    if (!hasConfiguration)
    {
      //TODO: exceptions
      throw Exception("ConfigurationNotReadyException");
      //throw ConfigurationNotReadyException();
    }

    if (!paramExists(key))
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      if (defaultValue != null)
      {
        return defaultValue;
      }
      //TODO: exceptions
      throw Exception("ParameterNotFoundException");
      //throw new ParameterNotFoundException(key);
    }
    return configuration.parameters[key];
  }

  /// <summary>
  /// Obtains a string value of a parameter defined in the <see cref="Configuration"/> in string form.
  /// </summary>
  /// <param name="key">The key matching the parameter name set on the back-end</param>
  /// <returns>The string value of the requested parameter if it exists</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if <see cref="Configuration"/> is not previously obtained</exception>
  /// <exception cref="ParameterNotFoundException">thrown if no parameter with that name present in the <see cref="Configuration"/></exception>
  String getStringParam(String key, { String? defaultValue, bool warn = true })
  {
    return getParam(key, defaultValue: defaultValue, warn: warn);
  }

  /// <summary>
  /// Obtains the value of a parameter defined in the <see cref="Configuration"/> in integer form.
  /// </summary>
  /// <param name="key">The key matching the parameter name set on the back-end</param>
  /// <returns>The integer value of the requested parameter if it exists</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if <see cref="Configuration"/> is not previously obtained</exception>
  /// <exception cref="ParameterNotFoundException">thrown if no parameter with that name present in the <see cref="Configuration"/></exception>
  /// <exception cref="InvalidParamFormatException">thrown if the parameter was unable to be converted to an integer</exception>
  int getIntParam(String key, { int? defaultValue, bool warn = true })
  {
    var str = getParam(key, defaultValue: defaultValue?.toString(), warn: warn);
    var result = int.tryParse(str);
    if (result != null)
    {
      return result;
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("InvalidParamFormatException");
    //throw new InvalidParamFormatException(key, typeof(int));
  }

  /// <summary>
  /// Obtains the value of a parameter defined in the <see cref="Configuration"/> in double form.
  /// </summary>
  /// <param name="key">The key matching the parameter name set on the back-end</param>
  /// <returns>The float value of the requested parameter if it exists</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if <see cref="Configuration"/> is not previously obtained</exception>
  /// <exception cref="ParameterNotFoundException">thrown if no parameter with that name present in the <see cref="Configuration"/></exception>
  /// <exception cref="InvalidParamFormatException">thrown if the parameter was unable to be converted to a float</exception>
  double getDoubleParam(String key, { double? defaultValue, bool warn = true })
  {
    var str = getParam(key, defaultValue: defaultValue?.toString(), warn: warn);
    var result = double.tryParse(str);
    if (result != null)
    {
      return result;
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("InvalidParamFormatException");
    //throw new InvalidParamFormatException(key, typeof(double));
  }


  /// <summary>
  /// Obtains an integer value of a parameter defined in the <see cref="Configuration"/> in string form.
  /// Uses whatever logic <see cref="bool.TryParse(string, out bool)" /> uses to convert to bool.
  /// </summary>
  /// <param name="key">The key matching the parameter name set on the back-end</param>
  /// <returns>The boolean value of the requested parameter if it exists</returns>
  /// <exception cref="ConfigurationNotReadyException">thrown if <see cref="Configuration"/> is not previously obtained</exception>
  /// <exception cref="ParameterNotFoundException">thrown if no parameter with that name present in the <see cref="Configuration"/></exception>
  /// <exception cref="InvalidParamFormatException">thrown if the parameter was unable to be converted to a boolean</exception>
  bool getBoolParam(String key, { bool? defaultValue, bool warn = true })
  {
    var str = getParam(key, defaultValue: defaultValue?.toString(), warn: warn);
    var result = str == "true" ? true : str == "false" ? false : null;
    if (result != null)
    {
      return result;
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("InvalidParamFormatException");
    //throw new InvalidParamFormatException(key, typeof(int));
  }

  //now all of these again but array versions
  static const String PARAM_LIST_SPLIT_DELIMITER = "|||";
  static const String PARAM_LIST_KEY_APPEND = "[]";

  //TODO: docs
  List<String> getStringParamList(String key, { List<String>? defaultValue, bool warn = true })
  {
    if (paramExists(key + PARAM_LIST_KEY_APPEND))
    {
      String unSplit = getStringParam(key + PARAM_LIST_KEY_APPEND);
      return unSplit.split(PARAM_LIST_SPLIT_DELIMITER);
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("ParameterNotFoundException");
    //throw new ParameterNotFoundException(key);
  }

  //TODO: docs
  List<int> getIntParamList(String key, { List<int>? defaultValue, bool warn = true })
  {
    if (paramExists(key + PARAM_LIST_KEY_APPEND))
    {
      String unSplit = getStringParam(key + PARAM_LIST_KEY_APPEND);
      List<String> split = unSplit.split(PARAM_LIST_SPLIT_DELIMITER);
      try
      {
        return split.map((e) => int.parse(e)).toList();
      }
      catch (e)
      {
        //TODO: exceptions
        throw Exception("InvalidParamFormatException");
        //throw new InvalidParamFormatException(key, typeof(int));
      }
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("ParameterNotFoundException");
    //throw new ParameterNotFoundException(key);
  }

  //TODO: docs
  List<double> getDoubleParamList(String key, { List<double>? defaultValue, bool warn = true })
  {
    if (paramExists(key + PARAM_LIST_KEY_APPEND))
    {
      String unSplit = getStringParam(key + PARAM_LIST_KEY_APPEND);
      List<String> split = unSplit.split(PARAM_LIST_SPLIT_DELIMITER);
      try
      {
        return split.map((e) => double.parse(e)).toList();
      }
      catch (e)
      {
        //TODO: exceptions
        throw Exception("InvalidParamFormatException");
        //throw new InvalidParamFormatException(key, typeof(int));
      }
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("ParameterNotFoundException");
    //throw new ParameterNotFoundException(key);
  }

  //TODO: docs
  List<bool> getBoolParamList(String key, { List<bool>? defaultValue, bool warn = true })
  {
    if (paramExists(key + PARAM_LIST_KEY_APPEND))
    {
      String unSplit = getStringParam(key + PARAM_LIST_KEY_APPEND);
      List<String> split = unSplit.split(PARAM_LIST_SPLIT_DELIMITER);
      return split.map((str) => str == "true").toList();
    }

    if (defaultValue != null)
    {
      if (warn) PlayURPluginLogger.warn("Tried to get value for $key but was not set. Defaulting to $defaultValue");
      return defaultValue;
    }

    //TODO: exceptions
    throw Exception("ParameterNotFoundException");
    //throw new ParameterNotFoundException(key);
  }

}