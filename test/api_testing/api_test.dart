import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'api_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late MockClient mockClient;
  late ApiService apiService;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(
      baseUrl: 'https://rollstrong-dev.brainxdemo.com/api/v1/',
      client: mockClient,
    );
  });

  test('returns requiresParentConsent data when API responds 401', () async {
    when(() => mockClient.post(
          Uri.parse('https://rollstrong-dev.brainxdemo.com/api/v1/auth/login'),
          body: any(named: 'body'),
        )).thenAnswer(
      (_) async => http.Response(
        jsonEncode({
          "message":
              "Your account requires parental consent. Please ask your parent/guardian to check their email and approve your account.",
          "status": 401,
          "data": {
            "userId": "695e0c1641adc352b4b8defa",
            "parentEmail": "alibuttm035@gmail.com",
            "requiresParentConsent": true
          }
        }),
        401,
      ),
    );

    final result = await apiService.userLogin();
    expect(result.httpStatusCode, 401);
    expect(result.status, 401);
    expect(result.data?.requiresParentConsent, true);
    expect(result.data?.parentEmail, 'alibuttm035@gmail.com');
    expect(result.data?.userId, '695e0c1641adc352b4b8defa');
  });
}
