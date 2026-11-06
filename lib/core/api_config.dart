/// Centralized API configuration for Zed Plus Field Operations.
class ApiConfig {
  /// Base API endpoint
  static const String baseUrl = 'https://private.zedplussecurity.com/api/v1';

  // Core endpoints
  static const String auth = '$baseUrl/auth';
  static const String login = '$baseUrl/auth/login';
  static const String attendance = '$baseUrl/attendance';
  static const String patrols = '$baseUrl/patrols';
  static const String supervisorRoutes = '$baseUrl/supervisor/routes';
  static const String incidents = '$baseUrl/incidents';
  static const String approvals = '$baseUrl/approvals';
  static const String dispatches = '$baseUrl/dispatches';
  static const String visitors = '$baseUrl/visitors';
  static const String users = '$baseUrl/users';
}

