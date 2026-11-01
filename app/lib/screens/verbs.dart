import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/tts.dart';

class VerbsScreen extends StatefulWidget {
  const VerbsScreen({super.key});

  @override
  State<VerbsScreen> createState() => _VerbsScreenState();
}

class _VerbsScreenState extends State<VerbsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final list = verbs
        .where((v) => v.base.contains(q) || v.es.toLowerCase().contains(q))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Buscar verbo (inglés o español)',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final v = list[i];
              return ListTile(
                title: Text(v.base,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${v.past} · ${v.participle}\n${v.es}'),
                isThreeLine: true,
                trailing: Chip(label: Text(v.level)),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => VerbDetail(verb: v))),
              );
            },
          ),
        ),
      ],
    );
  }
}

class VerbDetail extends StatelessWidget {
  final Verb verb;
  const VerbDetail({super.key, required this.verb});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget form(String label, String value) => Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Text(label, style: t.labelMedium),
                const SizedBox(height: 4),
                Text(value,
                    textAlign: TextAlign.center,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => Tts.instance.speak(value.split(' / ').first),
                ),
              ]),
            ),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(verb.base)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(verb.es, style: t.headlineSmall),
          const SizedBox(height: 12),
          Row(children: [
            form('Presente', verb.base),
            form('Pasado', verb.past),
            form('Participio', verb.participle),
          ]),
          const SizedBox(height: 16),
          Text('Ejemplos', style: t.titleLarge),
          const SizedBox(height: 8),
          ...verb.examples.map((e) => Card(
                child: ListTile(
                  title: Text(e.en),
                  subtitle: Text(e.es),
                  trailing: IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () => Tts.instance.speak(e.en),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
