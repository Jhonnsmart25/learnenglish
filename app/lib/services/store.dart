import 'package:shared_preferences/shared_preferences.dart';

/// Datos guardados en el teléfono.
class Store {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static bool get onboardingDone => _p.getBool('onboarding') ?? false;
  static set onboardingDone(bool v) {
    _p.setBool('onboarding', v);
  }

  static String? get email => _p.getString('email');
  static set email(String? v) {
    if (v == null) {
      _p.remove('email');
    } else {
      _p.setString('email', v);
    }
  }

  /// Última vez que se confirmó una suscripción activa (para uso sin internet).
  static int? get lastActiveMs => _p.getInt('lastActiveMs');
  static set lastActiveMs(int? v) {
    if (v == null) {
      _p.remove('lastActiveMs');
    } else {
      _p.setInt('lastActiveMs', v);
    }
  }
}
