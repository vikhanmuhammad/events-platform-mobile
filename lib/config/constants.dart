class Constants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.100:8081/api',
  );

  static const String wsBaseUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'ws://192.168.1.100:8081',
  );

  static const List<String> eventCategories = [
    'Sports',
    'Music',
    'Tech',
    'Art',
    'Food',
    'Social',
  ];

  static const String rsvpGoing = 'GOING';
  static const String rsvpInterested = 'INTERESTED';
  static const String rsvpCantGo = 'CANT_GO';
}