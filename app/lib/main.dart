import 'package:flutter/material.dart';

import 'screens/home.dart';
import 'screens/onboarding.dart';
import 'screens/paywall.dart';
import 'services/store.dart';
import 'services/subscription_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  runApp(const AprendeInglesApp());
}

class AprendeInglesApp extends StatelessWidget {
  const AprendeInglesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aprende Inglés',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      home: const Gate(),
    );
  }
}

enum _View { loading, onboarding, paywall, home }

/// Decide qué pantalla mostrar: bienvenida → suscripción → app.
class Gate extends StatefulWidget {
  const Gate({super.key});

  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  _View _view = _View.loading;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    if (!Store.onboardingDone) {
      setState(() => _view = _View.onboarding);
      return;
    }
    final email = Store.email;
    if (email == null) {
      setState(() => _view = _View.paywall);
      return;
    }
    try {
      final active = await SubscriptionService.isActive(email);
      if (active) Store.lastActiveMs = DateTime.now().millisecondsSinceEpoch;
      if (!mounted) return;
      setState(() => _view = active ? _View.home : _View.paywall);
    } catch (_) {
      // Sin internet: se permite entrar hasta 3 días después de la última
      // verificación exitosa.
      final last = Store.lastActiveMs;
      final recent = last != null &&
          DateTime.now().millisecondsSinceEpoch - last <
              const Duration(days: 3).inMilliseconds;
      if (!mounted) return;
      setState(() => _view = recent ? _View.home : _View.paywall);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_view) {
      case _View.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case _View.onboarding:
        return OnboardingScreen(onDone: () {
          Store.onboardingDone = true;
          setState(() => _view = _View.paywall);
        });
      case _View.paywall:
        return PaywallScreen(
            onActivated: () => setState(() => _view = _View.home));
      case _View.home:
        return HomeScreen(onLogout: () {
          Store.email = null;
          Store.lastActiveMs = null;
          setState(() => _view = _View.paywall);
        });
    }
  }
}
