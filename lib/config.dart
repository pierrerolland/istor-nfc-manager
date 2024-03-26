class AppConfig {
  static const String apiUrl = String.fromEnvironment('API_URL',
      defaultValue: 'http://10.0.2.2:3030');
}
