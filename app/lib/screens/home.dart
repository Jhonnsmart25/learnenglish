import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/store.dart';
import '../services/subscription_service.dart';
import 'examples.dart';
import 'exercises.dart';
import 'pronunciation.dart';
import 'verbs.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Verbos', 'Ejemplos', 'Audio', 'Ejercicios'];

  Future<void> _manageSubscription() async {
    final email = Store.email;
    if (email == null) return;
    try {
      final url = await SubscriptionService.createPortalUrl(email);
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo abrir la administración de suscripción.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'manage') _manageSubscription();
              if (v == 'logout') widget.onLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'manage', child: Text('Administrar suscripción')),
              PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: const [
        VerbsScreen(),
        ExamplesScreen(),
        PronunciationScreen(),
        ExercisesScreen(),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Verbos'),
          NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline), label: 'Ejemplos'),
          NavigationDestination(icon: Icon(Icons.volume_up), label: 'Audio'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Ejercicios'),
        ],
      ),
    );
  }
}
