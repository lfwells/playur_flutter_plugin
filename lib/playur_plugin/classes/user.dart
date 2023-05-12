class PlayURUser
{
  /// <summary>
  /// The user's ID
  /// </summary>
  late int id;

  /// <summary>
  /// The user's username
  /// </summary>
  late String name;

  /// <summary>
  /// Is the user listed as an owner of this game?
  /// </summary>
  bool get isGameOwner => accessLevel > noAccess;

  /// <summary>
  /// The user's defined access level as defined on Owners tab of the platform. Will be -1 if not an owner
  /// </summary>
  late int accessLevel = noAccess;
  static const int noAccess = -1;
}