import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';

/// Habla con tu servidor, que es quien conversa con Stripe.
/// La app NUNCA contiene la llave secreta de Stripe.
class SubscriptionService {
  static const _timeout = Duration(seconds: 15);
  static const _headers = {'Content-Type': 'application/json'};

  /// Devuelve la URL de Stripe Checkout (con 7 días de prueba).
  static Future<String> createCheckoutUrl(String email) async {
    final res = await http
        .post(Uri.parse('$apiBase/create-checkout-session'),
            headers: _headers, body: jsonEncode({'email': email}))
        .timeout(_timeout);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'No se pudo iniciar el pago');
    }
    return data['url'] as String;
  }

  /// true si la suscripción está en prueba (trialing) o activa.
  static Future<bool> isActive(String email) async {
    final uri = Uri.parse('$apiBase/subscription-status')
        .replace(queryParameters: {'email': email});
    final res = await http.get(uri).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('No se pudo verificar la suscripción');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['active'] == true;
  }

  /// URL del portal de Stripe donde el usuario cancela o cambia su tarjeta.
  static Future<String> createPortalUrl(String email) async {
    final res = await http
        .post(Uri.parse('$apiBase/create-portal-session'),
            headers: _headers, body: jsonEncode({'email': email}))
        .timeout(_timeout);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'No se pudo abrir el portal');
    }
    return data['url'] as String;
  }
}
