import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://d29qdzpk-8080.inc1.devtunnels.ms/api/hall-qr-tokens';
  print('Testing API: $url');
  
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      },
    ).timeout(Duration(seconds: 15));
    
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      print('Decoded Structure: $decoded');
    }
  } catch (e) {
    print('Error: $e');
  }
}
