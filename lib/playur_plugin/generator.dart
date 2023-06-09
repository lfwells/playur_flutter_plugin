import 'dart:convert';

import 'package:build/build.dart';
import 'package:playur_flutter_plugin/playur_plugin/playur_plugin.dart';
//import 'package:playur_flutter_plugin/playur_plugin/api.dart';
import 'package:yaml/yaml.dart';
import 'package:http/http.dart' as http;

EnumGenerator enumGenerator(BuilderOptions options) => EnumGenerator();

/// A really simple [Builder], it just makes copies of .txt files!
class EnumGenerator implements Builder {
  @override
  final buildExtensions = const {
    r'$package$': [
      'lib/playur_plugin/generated/playur_config.dart',
      'lib/playur_plugin/generated/action.dart',
      'lib/playur_plugin/generated/element.dart',
      'lib/playur_plugin/generated/experiment.dart',
      'lib/playur_plugin/generated/experiment_group.dart',
      'lib/playur_plugin/generated/analytics_column.dart',
      'lib/playur_plugin/generated/parameter.dart'
    ]
  };
  @override
  Future<void> build(BuildStep buildStep) async
  {
    //read in the game id and client secret from playur_config.yaml
    var options = await buildStep.readAsString(AssetId(buildStep.inputId.package, 'lib/playur_config.yaml'));
    var yaml = loadYaml(options)['playur'];
    var gameID = yaml['game_id'];
    var clientSecret = yaml['client_secret'];

    //loop over all allowedOuputs and extract the file name from the string
    await Future.forEach(buildStep.allowedOutputs, (element) async {
      var fileName = element.pathSegments.last;
      var name = fileName.substring(0, fileName.length - 5);

      if (name == "playur_config")
      {
        //generate a dart file with the game id and secret as const values in a class
        await buildStep.writeAsString(AssetId(buildStep.inputId.package, 'lib/playur_plugin/generated/playur_config.dart'), generateTokenFile(gameID, clientSecret));
      }
      else if (name == "parameter")
      {
        //TODO: code-gen parameter consts
      }
      else
      {
        //convert the name from snake_case to CamelCase
        name = name.split('_').map((e) => capitalize(e)).join();

        var values = await getValues(name, gameID, clientSecret);
        await buildStep.writeAsString(AssetId(buildStep.inputId.package, 'lib/playur_plugin/generated/$fileName'), generateEnum(name, values));
      }
    });
  }

  String generateTokenFile(int gameID, String clientSecret) {
    return """
// ignore_for_file: constant_identifier_names
// note: this file should not be committed to source control

class PlayURConfig
{
  static const int gameID = $gameID;
  static const String clientSecret = '$clientSecret';
}""";
  }

  Future<Map<String, int>> getValues(String name, int gameID, String clientSecret) async
  {
    try {
      //can't use the api line, since it imports material stuff
      //var values = await PlayURAPI.get("$name/listForGame.php", PlayURAPI.getWWWFormFromValues(gameID:gameID, clientSecret: clientSecret), debugOutput: false);
      var url = "${PlayURPlugin
          .serverURL}$name/listForGame.php?gameID=$gameID&clientSecret=$clientSecret";
      var response = await http.get(Uri.parse(url));
      var json = jsonDecode(response.body);
      return Map<String, int>.fromEntries((json['records'] as List<dynamic>).map((e) => MapEntry(e['name'], int.parse(e['id']))));
    }
    catch (e) {
      // ignore: avoid_print
      print(e);
      return {};
    }
  }

  String generateEnum(String name, Map<String, int> values)
  {
    var sb = StringBuffer();
    sb.writeln("""
// ignore_for_file: camel_case_types, constant_identifier_names
// note: this file should not be committed to source control

enum ${capitalize(name)} 
{
  __Invalid(-1, "__Invalid"),
  """);
    values.forEach((key, value) {
      var keySafe = _platformNameToValidEnumValue(key);
      if (keySafe == name) {
        keySafe = "${keySafe}_";
      }
      sb.writeln("\t$keySafe($value, \"$key\"),");
    });
    sb.writeln("""
  ;
  const $name(this.value, this.name);
  final int value;
  final String name;
  
  factory $name.fromValue(int value) {
    return $name.values.firstWhere((element) => element.value == value, orElse: () => $name.__Invalid);
  }
}""");
    return sb.toString();
  }

  //capitalize a string
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);


  String _platformNameToValidEnumValue(String input)
  {
    //remove special characters except spaces
    input = input.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');

    //capitalize each word and then remove spaces
    return input.split(' ').map((e) => capitalize(e)).join();

  }
}