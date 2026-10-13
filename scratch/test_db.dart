import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  const url = 'https://tyuogpbtxudhtxhfmezm.supabase.co';
  const key = 'sb_publishable_qOC4hvCWUdqOyHunlBLXCg_pvUvtb4E';
  final headers = {
    'apikey': key,
    'Authorization': 'Bearer $key',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // 1. Check notifications
  final notifRes = await http.get(Uri.parse('$url/rest/v1/notifications?limit=1'), headers: headers);
  print('notifications GET status: ${notifRes.statusCode}, body: ${notifRes.body}');

  // 2. Try POST empty to notifications to see missing fields or columns
  final postRes = await http.post(Uri.parse('$url/rest/v1/notifications'), headers: headers, body: jsonEncode({}));
  print('notifications POST empty status: ${postRes.statusCode}, body: ${postRes.body}');

  // 3. Check cart_items
  final cartRes = await http.get(Uri.parse('$url/rest/v1/cart_items?limit=1'), headers: headers);
  print('cart_items GET status: ${cartRes.statusCode}, body: ${cartRes.body}');
}
