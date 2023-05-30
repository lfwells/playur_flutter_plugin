# playur_flutter_plugin

A wrapper for the PlayUR plugin for Flutter

See https://playur.io for more information.

## Configuration
Create a file `playur_config.yaml` in your `lib` folder with the following contents:

```yaml
playur:
  game_id: <your game id here>
  client_secret: <your client secret here>
```
This file should NOT be committed to source control.

## Code Generation

This plugin uses code-generation to create enum values for the `Experiment`, `ExperimentGroup`, `Element`, `Action`, and `AnalyticsColumn` enums, as (future) `Parameter` const strings.

To trigger the code generation, run the following command from the root of the project:

```bash
flutter pub run build_runner build
```