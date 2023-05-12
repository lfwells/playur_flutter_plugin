/// <summary>
/// Represents the settings for an inidivdual user playing the game.
/// Calculated as a combination of global \ref elements and \ref parameters which can be overridden
/// at the Experiment and ExperimentGroup level.
/// </summary>
class PlayURConfiguration
{
  /// <summary>
  /// The ID of the current experiment being run.
  /// </summary>
  late int experimentID;

  /// <summary>
  /// The current experiment being run, in enum form.
  /// </summary>
  // TODO: enums
  //late Experiment experiment;

  /// <summary>
  /// The ID of the current experiment group this user has been allocated to.
  /// </summary>

  late int experimentGroupID;
  /// <summary>
  /// The current experiment group this user has been allocated to, in enum form.
  /// </summary>
  // TODO: enums
  //late ExperimentGroup experimentGroup;

  /// <summary>
  /// List of active Game Elements for this current configuration. If an element is not in this list, it is not active.
  /// </summary>
  // TODO: enums
  //late List<Element> elements;

  /// <summary>
  /// Key-Value-Pairs of the enabled Parameters for this current configuration.
  ///May be used for modifying UI text, or configuring enemy counts, etc etc.
  /// </summary>
  late Map<String, dynamic> parameters;

  /// <summary>
  /// The list of extra analytics columns, but sorted by custom sort order from admin page.
  /// </summary>
  // TODO: enums
  //late List<AnalyticsColumn> analyticsColumnsOrder;

  /// <summary>
  /// The build ID of the current configuration
  /// </summary>
  late int buildID;

  /// <summary>
  /// The branch of the current build
  /// </summary>
  late String branch;
}