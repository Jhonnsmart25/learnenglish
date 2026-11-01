import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../services/store.dart';
import '../services/subscription_service.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback onActivated;
  const PaywallScreen({super.key, required this.onActivated});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  late final TextEditingController _email =
      TextEditingController(text: Store.email ?? '');
  bool _loading = false;
  bool _opened = false;
  String? _message;

  static final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  String? _validEmail() {
    final e = _email.text.trim().toLowerCase();
    if (!_emailRe.hasMatch(e)) {
      setState(() => _message = 'Escribe un correo válido.');
      return null;
    }
    return e;
  }

  Future<void> _start() async {
    final email = _validEmail();
    if (email == null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      Store.email = email;
      final url = await SubscriptionService.createCheckoutUrl(email);
      final ok = await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('No se pudo abrir el navegador');
      setState(() => _opened = true);
    } catch (e) {
      setState(() => _message = 'No pudimos iniciar el pago. Revisa tu '
          'conexión e inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _check() async {
    final email = _validEmail();
    if (email == null) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final active = await SubscriptionService.isActive(email);
      if (active) {
        Store.email = email;
        Store.lastActiveMs = DateTime.now().millisecondsSinceEpoch;
        widget.onActivated();
        return;
      }
      setState(() => _message =
          'Todavía no vemos una suscripción activa con ese correo.');
    } catch (_) {
      setState(() => _message = 'No pudimos verificar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.workspace_premium, size: 80, color: scheme.primary),
            const SizedBox(height: 16),
            Text('Empieza gratis $trialDays días',
                textAlign: TextAlign.center,
                style: t.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Acceso completo a todo el contenido.',
                textAlign: TextAlign.center, style: t.bodyLarge),
            const SizedBox(height: 24),
            const _Benefit(Icons.menu_book, 'Verbos con pasado y participio'),
            const _Benefit(Icons.chat_bubble_outline, 'Ejemplos con traducción'),
            const _Benefit(Icons.volume_up, 'Audio para practicar pronunciación'),
            const _Benefit(Icons.quiz, 'Ejercicios de práctica ilimitados'),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Tu correo electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _start,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Empezar mis $trialDays días gratis'),
              ),
            ),
            if (_opened) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _check,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Ya me suscribí, entrar'),
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 16),
            Text(
              'Después de los $trialDays días se cobra $priceLabel. '
              'Puedes cancelar en cualquier momento desde la app, antes de que '
              'termine la prueba, y no se te cobrará.',
              textAlign: TextAlign.center,
              style: t.bodySmall,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : _check,
              child: const Text('Ya tengo cuenta · Restaurar acceso'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Benefit(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ]),
      );
}
