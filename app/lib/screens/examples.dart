import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/tts.dart';

class ExamplesScreen extends StatefulWidget {
  const ExamplesScreen({super.key});

  @override
  State<ExamplesScreen> createState() => _ExamplesScreenState();
}

class _ExamplesScreenState extends State<ExamplesScreen> {
  String? _level; // null = todos
  final Set<String> _revealed = {};

  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<Verb, Example>>[
      for (final v in verbs)
        if (_level == null || v.level == _level)
          for (final e in v.examples) MapEntry(v, e),
    ];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                  label: const Text('Todos'),
                  selected: _level == null,
                  onSelected: (_) => setState(() => _level = null)),
              for (final l in ['A1', 'A2', 'B1'])
                ChoiceChip(
                    label: Text(l),
                    selected: _level == l,
                    onSelected: (_) => setState(() => _level = l)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, i) {
              final verb = items[i].key;
              final ex = items[i].value;
              final shown = _revealed.contains(ex.en);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  title: Text(ex.en),
                  subtitle: Text(
                    shown ? ex.es : 'Toca para ver la traducción · ${verb.base}',
                    style: TextStyle(
                        fontStyle: shown ? FontStyle.normal : FontStyle.italic),
                  ),
                  onTap: () => setState(() {
                    shown ? _revealed.remove(ex.en) : _revealed.add(ex.en);
                  }),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: 'Lento',
                      icon: const Icon(Icons.slow_motion_video),
                      onPressed: () => Tts.instance.speak(ex.en, rate: 0.3),
                    ),
                    IconButton(
                      tooltip: 'Escuchar',
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => Tts.instance.speak(ex.en),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
