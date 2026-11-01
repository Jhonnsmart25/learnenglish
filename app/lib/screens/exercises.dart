import 'package:flutter/material.dart';

import '../data/content.dart';
import '../services/tts.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late List<Question> _quiz = buildQuiz();
  int _i = 0;
  int _score = 0;
  int? _selected;

  bool get _finished => _i >= _quiz.length;

  void _choose(int idx) {
    if (_selected != null) return;
    setState(() {
      _selected = idx;
      if (idx == _quiz[_i].answer) _score++;
    });
  }

  void _next() => setState(() {
        _i++;
        _selected = null;
      });

  void _restart() => setState(() {
        _quiz = buildQuiz();
        _i = 0;
        _score = 0;
        _selected = null;
      });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (_finished) {
      final pct = (_score / _quiz.length * 100).round();
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(pct >= 70 ? Icons.emoji_events : Icons.trending_up,
                  size: 90, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text('$_score de ${_quiz.length} correctas',
                  style: t.headlineMedium),
              const SizedBox(height: 8),
              Text(pct >= 70
                  ? '¡Muy bien! Sigue practicando.'
                  : 'Cada intento te acerca más. ¡Inténtalo otra vez!'),
              const SizedBox(height: 24),
              FilledButton(
                  onPressed: _restart, child: const Text('Nueva práctica')),
            ],
          ),
        ),
      );
    }

    final q = _quiz[_i];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LinearProgressIndicator(value: _i / _quiz.length),
        const SizedBox(height: 8),
        Text('Pregunta ${_i + 1} de ${_quiz.length}', style: t.labelMedium),
        const SizedBox(height: 16),
        Text(q.prompt, style: t.titleLarge),
        if (q.speakText != null) ...[
          const SizedBox(height: 12),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => Tts.instance.speak(q.speakText!),
              icon: const Icon(Icons.volume_up),
              label: const Text('Escuchar'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        for (var idx = 0; idx < q.options.length; idx++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: _OptionTile(
              text: q.options[idx],
              state: _selected == null
                  ? _OptionState.idle
                  : idx == q.answer
                      ? _OptionState.correct
                      : idx == _selected
                          ? _OptionState.wrong
                          : _OptionState.idle,
              onTap: () => _choose(idx),
            ),
          ),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          Text(
            _selected == q.answer
                ? '¡Correcto! ${q.explanation}'
                : 'Respuesta correcta: ${q.options[q.answer]}\n${q.explanation}',
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _next,
              child: Text(_i == _quiz.length - 1 ? 'Ver resultado' : 'Siguiente')),
        ],
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.text, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color? bg;
    IconData? icon;
    switch (state) {
      case _OptionState.correct:
        bg = Colors.green.withOpacity(0.2);
        icon = Icons.check_circle;
        break;
      case _OptionState.wrong:
        bg = scheme.errorContainer;
        icon = Icons.cancel;
        break;
      case _OptionState.idle:
        break;
    }
    return Card(
      color: bg,
      child: ListTile(
        title: Text(text),
        trailing: icon == null ? null : Icon(icon),
        onTap: onTap,
      ),
    );
  }
}
