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
      'lib/playur_plugin/generated/action.dart',
      'lib/playur_plugin/generated/element.dart',
      'lib/playur_plugin/generated/experiment.dart',
      'lib/playur_plugin/generated/experiment_group.dart',
      'lib/playur_plugin/generated/analytics_column.dart',
      //TODO: 'lib/playur_plugin/generated/parameter.dart'
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

      //convert the name from snake_case to CamelCase
      name = name.split('_').map((e) => capitalize(e)).join();

      var values = await getValues(name, gameID, clientSecret);
      await buildStep.writeAsString(AssetId(buildStep.inputId.package, 'lib/playur_plugin/generated/$fileName'), generateEnum(name, values));
    });
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
    sb.writeln("// ignore_for_file: camel_case_types, constant_identifier_names\n\nclass ${capitalize(name)} {");
    values.forEach((key, value) {
      sb.writeln("\tstatic const $key = $value;");
    });
    sb.writeln("}");
    return sb.toString();
  }

  //capitalize a string
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}