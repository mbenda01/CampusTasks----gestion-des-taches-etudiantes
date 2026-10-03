class Configuration {
  const Configuration._();

  static const String urlApi = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String version = '1.0.0+1';
}
