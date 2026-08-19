import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/Rihla_BackEnd/api';

  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_login.php'),
      body: {'email': email, 'password': password},
    );

    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getMetroStatuses() async {
    final response = await http.get(Uri.parse('$baseUrl/get_metroStatus.php'));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/getUsers.php'));

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin_get_user_details.php?user_id=$userId'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeSavedStation({
    required String userId,
    required String stationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/removestations.php'),
      body: {'user_id': userId, 'station_id': stationId},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeUser(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_remove_user.php'),
      body: {'user_id': userId},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getStations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin_stations.php?action=list'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> stationAction(
    Map<String, String> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_stations.php'),
      body: body,
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getTicketPrices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin_ticket_prices.php'),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> saveTicketPrices({
    required String twoHoursPrice,
    required String sevenDaysPrice,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_ticket_prices.php'),
      body: {
        'two_hours_price': twoHoursPrice,
        'seven_days_price': sevenDaysPrice,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateMetroStatus({
    required String lineName,
    required String status,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_metroStatus.php'),
      body: {'line_name': lineName, 'status': status},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendGlobalNotification({
    required String title,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_notifications.php'),
      body: {'title': title, 'message': message},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateAdminProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_update_profile.php'),
      body: {'id': id, 'name': name, 'email': email},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> changeAdminPassword({
    required String id,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_change_password.php'),
      body: {
        'id': id,
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateUser({
    required int id,
    required String name,
    required String email,
    required String password,
    required bool isStudent,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin_update_user.php'),
      body: {
        'id': id.toString(),
        'name': name,
        'email': email,
        'password': password,
        'is_student': isStudent ? '1' : '0',
      },
    );

    return jsonDecode(response.body);
  }
}
