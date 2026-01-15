import 'dart:convert';

import 'package:http/http.dart' as http;

class LoginData {
  final String userId;
  final String parentEmail;
  final bool requiresParentConsent;

  const LoginData({
    required this.userId,
    required this.parentEmail,
    required this.requiresParentConsent,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      userId: json['userId']?.toString() ?? '',
      parentEmail: json['parentEmail']?.toString() ?? '',
      requiresParentConsent: json['requiresParentConsent'] == true,
    );
  }
}

class LoginApiResponse {
  final String message;
  final int status;
  final LoginData? data;
  final int httpStatusCode;

  const LoginApiResponse({
    required this.message,
    required this.status,
    required this.data,
    required this.httpStatusCode,
  });

  factory LoginApiResponse.fromJson(
    Map<String, dynamic> json, {
    required int httpStatusCode,
  }) {
    final dataJson = json['data'];
    return LoginApiResponse(
      message: json['message']?.toString() ?? '',
      status:
          (json['status'] is int)
              ? (json['status'] as int)
              : int.tryParse(json['status']?.toString() ?? '') ??
                  httpStatusCode,
      data:
          dataJson is Map<String, dynamic>
              ? LoginData.fromJson(dataJson)
              : null,
      httpStatusCode: httpStatusCode,
    );
  }
}

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Future<LoginApiResponse> userLogin() async {
    final response = await client.post(
      Uri.parse('${baseUrl}auth/login'),
      body: {'email': 'ali.iqbal@brainxtech.com', 'password': 'Admin @12.'},
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response');
    }

    return LoginApiResponse.fromJson(
      decoded,
      httpStatusCode: response.statusCode,
    );
  }
}
