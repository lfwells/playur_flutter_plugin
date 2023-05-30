# playur_flutter_plugin

A wrapper for the PlayUR plugin for Flutter

See https://playur.io for more information.

## Code Generation

This plugin uses code-generation to create enum values for the `Experiment`, `ExperimentGroup`, `Element`, `Action`, and `AnalyticsColumn` enums, as (future) `Parameter` const strings.

To trigger the code generation, run the following command from the root of the project:

```bash
flutter pub run build_runner build
```