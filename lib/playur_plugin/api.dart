import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:playur_flutter_plugin/playur_plugin/log.dart';
import 'package:playur_flutter_plugin/playur_plugin/provider.dart';
import 'package:provider/provider.dart';

class PlayURAPI
{
  /// <summary>The base url of the server instance through which all Rest requests will go.
  /// Should point to the "api" sub-directory on the server.
  /// </summary>
  static const String serverURL = "https://playur.io/api/";

  /// <summary>
  /// Standard HTTP GET request.
  /// Used for requesting information FROM the server.
  /// Has a callback for reading the response.
  /// </summary>
  /// <param name="page">The endpoint we are requesting (relative to <see cref="PlayURPlugin.SERVER_URL"/>/api/</param>
  /// <param name="form">Dictionary of key value pairs of information we want to send to the server.</param>
  /// <param name="callback">Callback for handling response from the server.</param>
  /// <param name="debugOutput">Optionally debug to the Unity console a bunch of information about how the request occurred.
  /// Use only when things are failing and we need to know what the server is directly saying.</param>
  /// <exception cref="ServerCommunicationException">thrown when the server is unreachable.</exception>
  static Future<ServerCallback> get(String page, Map<String, String>? form, { bool debugOutput = false }) async
  {
    var kvp = "?";
    if (form != null)
    {
      for (var key in form.entries)
      {
        kvp += "${key.key}=${key.value}&";
      }
    }

    var url = "$serverURL$page/$kvp";

    if (page.indexOf(".php") > 0) {
      url = serverURL + page + kvp;
    }
    if (debugOutput) PlayURPluginLogger.log("GET $url");


    var response = await http.get(Uri.parse(url));
    //return the response
    //return response.body;


    if (debugOutput) PlayURPluginLogger.log(response.body);

    //TODO: throw errors
    /*
    if (www.isNetworkError)
    {
      PlayURPlugin.Log("Response Code: " + www.responseCode);
      throw new ServerCommunicationException(www.error);
    }
    else if (www.isHttpError)
    {
      json = JSON.Parse(www.downloadHandler.text);
      PlayURPlugin.Log("Response Code: " + www.responseCode);

      if (callback != null) callback(false, json);
      yield break;
    }*/

    dynamic json;
    try
    {
      json = jsonDecode(response.body);
    }
    catch (e)
    {
      PlayURPluginLogger.log(e.toString());
      //TODO: throw errors
      //throw new ServerCommunicationException("${"JSON Parser Error: " + e.Message+"\nRaw: '"+www.downloadHandler.text}'");
    }

    return ServerCallback(!((json["success"] == null) || (json["success"] is! bool) || (json["success"] as bool) != true), json);
  }


  /// <summary>
  /// Standard HTTP POST request.
  /// Used for sending NEW data TO the server.
  /// Has a callback for reading the response.
  /// </summary>
  /// <param name="page">The endpoint we are requesting (relative to <see cref="PlayURPlugin.SERVER_URL"/>/api/</param>
  /// <param name="form">Dictionary of key value pairs of information representing the object we want to send to the server.</param>
  /// <param name="callback">Callback for handling response from the server.</param>
  /// <param name="HTMLencode">Optionally convert form items special characters using <code>WebUtility.HtmlEncode</code>. </param>
  /// <param name="debugOutput">Optionally debug to the Unity console a bunch of information about how the request occurred. </param>
  /// Use only when things are failing and we need to know what the server is directly saying.</param>
  /// <exception cref="ServerCommunicationException">thrown when the server is unreachable.</exception>
  static Future<ServerCallback> post(String page, Map<String, String> form, { bool HTMLencode = false, bool debugOutput = false }) async
  {
    //TODO: implement HTMLencode
    if (HTMLencode) {
      //jsonOut[kvp.Key] = WebUtility.HtmlEncode(kvp.Value);
    }

    var url = "$serverURL$page/";//the slash on the end is actually important....
    if (debugOutput) PlayURPluginLogger.log("POST $url");

    var response = await http.post(Uri.parse(url), body: form, encoding: Encoding.getByName("utf-8"));

    if (debugOutput) PlayURPluginLogger.log(response.body);

    //TODO: implement error check
    /*
    if (www.isNetworkError)
    {
    PlayURPlugin.Log("Response Code: " + www.responseCode);
    throw new ServerCommunicationException(www.error);
    }
    else if (www.isHttpError)
    {
    PlayURPlugin.Log(www.downloadHandler.text);
    json = JSON.Parse(www.downloadHandler.text);
    PlayURPlugin.Log("Response Code: " + www.responseCode);
    if (debugOutput) PlayURPlugin.Log(json);
    if (callback != null) callback(false, null);
    yield break;
    }*/


    dynamic json;
    try
    {
      json = jsonDecode(response.body);
    }
    catch (e)
    {
      PlayURPluginLogger.log(e.toString());
      //TODO: throw errors
      //throw new ServerCommunicationException("${"JSON Parser Error: " + e.Message+"\nRaw: '"+www.downloadHandler.text}'");
    }

    return ServerCallback(!((json["success"] == null) || (json["success"] is! bool) || (json["success"] as bool) != true), json);
  }

  /// <summary>
  /// Standard HTTP PUT request.
  /// Used for UPDATING data on the server.
  /// Has a callback for reading the response.
  /// </summary>
  /// <param name="page">The endpoint we are requesting (relative to <see cref="PlayURPlugin.SERVER_URL"/>/api/</param>
  /// <param name="id">id of the object we are updating data for.</param>
  /// <param name="form">Dictionary of key value pairs of information we want to send to the server.</param>
  /// <param name="callback">Callback for handling response from the server.</param>
  /// <param name="debugOutput">Optionally debug to the Unity console a bunch of information about how the request occurred.
  /// Use only when things are failing and we need to know what the server is directly saying.</param>
  /// <exception cref="ServerCommunicationException">thrown when the server is unreachable.</exception>
  static Future<ServerCallback> put(String page, Map<String, String> form, { bool HTMLencode = false, bool debugOutput = false }) async
  {
    //TODO: implement HTMLencode
    if (HTMLencode) {
      //jsonOut[kvp.Key] = WebUtility.HtmlEncode(kvp.Value);
    }

    var url = "$serverURL$page/";//the slash on the end is actually important....
    if (debugOutput) PlayURPluginLogger.log("POST $url");

    var response = await http.put(Uri.parse(url), body: form, encoding: Encoding.getByName("utf-8"));

    if (debugOutput) PlayURPluginLogger.log(response.body);

    //TODO: implement error check
    /*
    if (www.isNetworkError)
    {
    PlayURPlugin.Log("Response Code: " + www.responseCode);
    throw new ServerCommunicationException(www.error);
    }
    else if (www.isHttpError)
    {
    PlayURPlugin.Log(www.downloadHandler.text);
    json = JSON.Parse(www.downloadHandler.text);
    PlayURPlugin.Log("Response Code: " + www.responseCode);
    if (debugOutput) PlayURPlugin.Log(json);
    if (callback != null) callback(false, null);
    yield break;
    }*/


    dynamic json;
    try
    {
      json = jsonDecode(response.body);
    }
    catch (e)
    {
      PlayURPluginLogger.log(e.toString());
      //TODO: throw errors
      //throw new ServerCommunicationException("${"JSON Parser Error: " + e.Message+"\nRaw: '"+www.downloadHandler.text}'");
    }

    return ServerCallback(!((json["success"] == null) || (json["success"] is! bool) || (json["success"] as bool) != true), json);
  }

  /// <summary>
  /// Helper function for building the <c>form</c> paramaters to the <see cref="Rest"/> class functions.
  /// Use this because it will automatically populate with the userID (from <see cref="PlayURPlugin.instance.user.id" />)
  /// and gameID (from <see cref="PlayURPlugin.instance.gameID"/>).
  /// Uses the terminology "WWWForm" because this class previously used <see cref="WWWForm"/> objects.
  /// </summary>
  /// <returns>A new Dictionary suitable for use as a <c>form parameter</c>.</returns>
  static Map<String, String> getWWWForm(BuildContext context)
  {
    PlayURProvider provider;
    try
    {
      provider = Provider.of<PlayURProvider>(context, listen: false);
    }
    catch (e)
    {
      throw Exception("PlayURProvider not found in context. Make sure you have a PlayURProvider widget in your widget tree.");
    }

    var form = <String, String>{};

    // TODO: handle currently logged in user
    //if (PlayURPlugin.instance.user != null) form.Add("userID", PlayURPlugin.instance.user.id.ToString());

    form["gameID"] = provider.gameID.toString();
    form["clientSecret"] = provider.clientSecret;

    return form;
  }
}

class ServerCallback
{
  ServerCallback(this.success, this.result);

  final bool success;
  final Map<String, dynamic> result;
}