import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/tts.dart';

/// Práctica de pronunciación: escucha las tres formas de cada verbo.
class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen> {
  double _rate = 0.45;
  String? _playing;

  Future<void> _playForms(Verb v) async {
    setState(() => _playing = v.base);
    final forms = <String>{
      v.base,
      v.past.split(' / ').first,
      v.participle,
    }.toList(); // sin repetir (ej. read / read / read)
    for (final f in forms) {
      if (_playing != v.base) break; // se detuvo
      await Tts.instance.speak(f, rate: _rate);
    }
    if (mounted) setState(() => _playing = null);
  }

  Future<void> _stop() async {
    await Tts.instance.stop();
    if (mounted) setState(() => _playing = null);
  }

  @override
  void dispose() {
    Tts.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            const Icon(Icons.speed),
            Expanded(
              child: Slider(
                value: _rate,
                min: 0.25,
                max: 0.7,
                divisions: 9,
                label: _rate < 0.4 ? 'Lento' : (_rate < 0.55 ? 'Normal' : 'Rápido'),
                onChanged: (v) => setState(() => _rate = v),
              ),
            ),
          ]),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Toca ▶ para escuchar: presente → pasado → participio'),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: verbs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final v = verbs[i];
              final playing = _playing == v.base;
              return ListTile(
                title: Text('${v.base} · ${v.past} · ${v.participle}'),
                subtitle: Text(v.es),
                trailing: IconButton(
                  icon: Icon(playing ? Icons.stop_circle : Icons.play_circle),
                  iconSize: 32,
                  onPressed: playing ? _stop : () => _playForms(v),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
