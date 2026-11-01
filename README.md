# Aprende Inglés — app Android (Flutter) + servidor Stripe

```
aprende_ingles/
├── app/      App Flutter (Android)
└── server/   Servidor Node.js que habla con Stripe
```

## Qué incluye

**App** (4 secciones + flujo de suscripción)
- **Bienvenida**: 3 pantallas que explican el valor y la prueba gratis.
- **Suscripción**: correo → Stripe Checkout con 7 días gratis → la app verifica el estado.
- **Verbos**: 19 verbos (A1–B1) con presente, pasado y participio; buscador; detalle con ejemplos.
- **Ejemplos**: oraciones con traducción oculta, filtro por nivel, audio normal y lento.
- **Audio**: práctica de pronunciación (presente → pasado → participio) con control de velocidad. Usa la voz del teléfono (text-to-speech), así que no necesitas grabar archivos.
- **Ejercicios**: quiz de 10 preguntas (pasado, significado, completar oración, escuchar y elegir).
- Menú: administrar suscripción (portal de Stripe) y cerrar sesión.

**Servidor**
- `POST /create-checkout-session` → sesión de pago con `trial_period_days: 7` (pide tarjeta desde el inicio).
- `GET /subscription-status?email=` → `active: true` si está en prueba (`trialing`) o pagando (`active`).
- `POST /create-portal-session` → portal de Stripe para cancelar o cambiar tarjeta.

## 1. Configura Stripe

1. Crea cuenta en stripe.com y usa **modo de prueba**.
2. *Product catalog* → crea un producto “Aprende Inglés” con precio **recurrente mensual** (ej. $99 MXN). Copia el `price_...`.
3. *Settings → Billing → Customer portal* → actívalo (necesario para que el usuario pueda cancelar).
4. *Developers → API keys* → copia la llave secreta `sk_test_...`.

## 2. Corre el servidor

```bash
cd server
npm install
cp .env.example .env     # llena STRIPE_SECRET_KEY y STRIPE_PRICE_ID
npm start
```

Prueba: `http://localhost:4242/health` debe responder `{"ok":true}`.

## 3. Prepara y corre la app

Necesitas [Flutter](https://docs.flutter.dev/get-started/install) y Android Studio.

```bash
cd app
flutter create . --org com.tuempresa --project-name aprende_ingles --platforms android
flutter pub get
```

Edita `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- Necesario en Android 11+ para abrir el navegador y para el audio (TTS) -->
    <queries>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
        <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>
    </queries>

    <application
        android:usesCleartextTraffic="true"   <!-- SOLO para pruebas con http://10.0.2.2; quítalo en producción -->
        ...>
```

Ejecuta en el emulador (el servidor corre en tu computadora, por eso `10.0.2.2`):

```bash
flutter run
```

Prueba de pago: tarjeta `4242 4242 4242 4242`, cualquier fecha futura y CVC.
Después toca **“Ya me suscribí, entrar”**.

> En un teléfono físico, usa la IP de tu computadora en la red local:
> `flutter run --dart-define=API_BASE=http://192.168.1.50:4242`

## 4. Publicar

1. Sube `server/` a un hosting con HTTPS (Render, Railway, Fly.io…) y define las variables de `.env` ahí (`BASE_URL` = tu dominio).
2. Cambia a llaves y precio **live** de Stripe.
3. Compila: `flutter build appbundle --dart-define=API_BASE=https://api.tudominio.com --dart-define=PRICE_LABEL="\$99 MXN al mes"`
4. Quita `usesCleartextTraffic` del manifest.

## ⚠️ Pendientes importantes antes de lanzar

1. **Política de Google Play.** Google exige su sistema de cobro (Play Billing) para suscripciones a contenido digital que se usa *dentro* de la app. Este proyecto cobra con Stripe en la web, lo cual puede ser rechazado según el país y cómo se presente. Antes de publicar revisa la política de “Payments” de Play Console, o considera Play Billing (Google cobra comisión). Si distribuyes el APK por tu cuenta (fuera de Play Store), no aplica.
2. **Identidad = solo correo.** Cualquiera que escriba el correo de otra persona suscrita obtendría acceso. Para producción agrega verificación (código por correo, Firebase Auth o Google Sign-In) y valida la sesión en el servidor.
3. **Contenido.** Hay 19 verbos de muestra. Para crecer, edita `app/lib/data/content.dart` (o muévelo a una base de datos/JSON remoto).
4. **Aviso legal.** Necesitas política de privacidad y términos (la Play Store los pide) y mostrar claramente el precio y la renovación — la pantalla de suscripción ya lo hace.
5. **Webhooks de Stripe** (opcional): hoy el servidor consulta a Stripe en cada verificación, lo cual es simple y suficiente para empezar.
6. El código **no se ha compilado** aún (Flutter no estaba disponible donde se generó). Si `flutter run` muestra algún error, pásamelo y lo corrijo.
