/// Dirección de tu servidor (el de la carpeta /server).
/// En el emulador de Android, 10.0.2.2 apunta a tu computadora.
/// En producción usa tu dominio con HTTPS:
///   flutter build apk --dart-define=API_BASE=https://api.tudominio.com
const String apiBase =
    String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:4242');

/// Texto del precio que se muestra en la pantalla de suscripción.
/// Debe coincidir con el precio real que creaste en Stripe.
const String priceLabel =
    String.fromEnvironment('PRICE_LABEL', defaultValue: r'$99 MXN al mes');

const int trialDays = 7;
