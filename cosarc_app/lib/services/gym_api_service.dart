import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/supabase_config.dart';

class GymApiService {
  static const String _gatewayUrl = 'https://ccmalnekezlebsqxxlds.supabase.co/functions/v1/gym-gateway';
  
  Future<dynamic> callGateway(String action, [Map<String, dynamic>? payload]) async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      throw Exception('User is not authenticated');
    }
    
    final response = await http.post(
      Uri.parse(_gatewayUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode({
        'action': action,
        'payload': payload ?? {},
      }),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final json = jsonDecode(response.body);
      return json;
    } else {
      throw Exception('Gateway error: ${response.statusCode} - ${response.body}');
    }
  }
}
