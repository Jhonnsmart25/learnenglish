import 'dart:math';

class Example {
  final String en;
  final String es;

  /// Forma del verbo tal como aparece en la oración (para los ejercicios).
  final String form;
  const Example(this.en, this.es, this.form);

  String get blank => en.replaceFirst(form, '____');
}

class Verb {
  final String base;
  final String past;
  final String participle;
  final String es;
  final String level; // A1, A2, B1
  final List<Example> examples;
  const Verb(this.base, this.past, this.participle, this.es, this.level,
      this.examples);
}

const List<Verb> verbs = [
  Verb('be', 'was / were', 'been', 'ser, estar', 'A1', [
    Example('I am a student.', 'Soy estudiante.', 'am'),
    Example('They were at home yesterday.', 'Ayer estuvieron en casa.', 'were'),
  ]),
  Verb('have', 'had', 'had', 'tener', 'A1', [
    Example('She has two brothers.', 'Ella tiene dos hermanos.', 'has'),
    Example('We had dinner at eight.', 'Cenamos a las ocho.', 'had'),
  ]),
  Verb('go', 'went', 'gone', 'ir', 'A1', [
    Example('I go to work by bus.', 'Voy al trabajo en autobús.', 'go'),
    Example('He went to Mexico last year.', 'Él fue a México el año pasado.',
        'went'),
  ]),
  Verb('do', 'did', 'done', 'hacer', 'A1', [
    Example('I did my homework.', 'Hice mi tarea.', 'did'),
    Example('She does yoga every morning.', 'Ella hace yoga cada mañana.',
        'does'),
  ]),
  Verb('make', 'made', 'made', 'hacer, fabricar', 'A1', [
    Example('She makes coffee every morning.',
        'Ella prepara café cada mañana.', 'makes'),
    Example('We made a cake yesterday.', 'Ayer hicimos un pastel.', 'made'),
  ]),
  Verb('take', 'took', 'taken', 'tomar, llevar', 'A1', [
    Example('I take the bus to school.', 'Tomo el autobús a la escuela.',
        'take'),
    Example('He took a photo of the beach.', 'Él tomó una foto de la playa.',
        'took'),
  ]),
  Verb('see', 'saw', 'seen', 'ver', 'A1', [
    Example('I see a bird in the tree.', 'Veo un pájaro en el árbol.', 'see'),
    Example('We saw a movie last night.', 'Vimos una película anoche.', 'saw'),
  ]),
  Verb('eat', 'ate', 'eaten', 'comer', 'A1', [
    Example('They eat breakfast at seven.', 'Ellos desayunan a las siete.',
        'eat'),
    Example('I ate tacos for lunch.', 'Comí tacos en la comida.', 'ate'),
  ]),
  Verb('drink', 'drank', 'drunk', 'beber', 'A1', [
    Example('She drinks water all day.', 'Ella bebe agua todo el día.',
        'drinks'),
    Example('He drank a glass of milk.', 'Él bebió un vaso de leche.', 'drank'),
  ]),
  Verb('come', 'came', 'come', 'venir', 'A1', [
    Example('Come here, please.', 'Ven aquí, por favor.', 'Come'),
    Example('They came late to the party.', 'Llegaron tarde a la fiesta.',
        'came'),
  ]),
  Verb('speak', 'spoke', 'spoken', 'hablar', 'A2', [
    Example('Do you speak English?', '¿Hablas inglés?', 'speak'),
    Example('She spoke with her teacher.', 'Ella habló con su maestro.',
        'spoke'),
  ]),
  Verb('write', 'wrote', 'written', 'escribir', 'A2', [
    Example('I write emails at work.', 'Escribo correos en el trabajo.',
        'write'),
    Example('He wrote a letter to his friend.',
        'Él escribió una carta a su amigo.', 'wrote'),
  ]),
  Verb('read', 'read', 'read', 'leer', 'A2', [
    Example('I read a book every month.', 'Leo un libro cada mes.', 'read'),
    Example('She has read this story twice.',
        'Ella ha leído esta historia dos veces.', 'read'),
  ]),
  Verb('give', 'gave', 'given', 'dar', 'A2', [
    Example('I give my mom flowers.', 'Le doy flores a mi mamá.', 'give'),
    Example('He gave me a gift.', 'Él me dio un regalo.', 'gave'),
  ]),
  Verb('know', 'knew', 'known', 'saber, conocer', 'A2', [
    Example('I know the answer.', 'Sé la respuesta.', 'know'),
    Example('We knew the teacher.', 'Conocíamos al maestro.', 'knew'),
  ]),
  Verb('learn', 'learned', 'learned', 'aprender', 'A2', [
    Example('I learn ten words a day.', 'Aprendo diez palabras al día.',
        'learn'),
    Example('She learned to swim last summer.',
        'Ella aprendió a nadar el verano pasado.', 'learned'),
  ]),
  Verb('choose', 'chose', 'chosen', 'elegir', 'B1', [
    Example('You can choose any color.', 'Puedes elegir cualquier color.',
        'choose'),
    Example('They chose the red car.', 'Eligieron el coche rojo.', 'chose'),
  ]),
  Verb('build', 'built', 'built', 'construir', 'B1', [
    Example('They build houses in my town.',
        'Construyen casas en mi pueblo.', 'build'),
    Example('He built a small boat.', 'Él construyó un bote pequeño.', 'built'),
  ]),
  Verb('begin', 'began', 'begun', 'comenzar', 'B1', [
    Example('The class begins at nine.', 'La clase comienza a las nueve.',
        'begins'),
    Example('We began the project in May.',
        'Comenzamos el proyecto en mayo.', 'began'),
  ]),
];

// ---------------------------------------------------------------- Ejercicios

class Question {
  final String prompt;
  final String? speakText; // si no es null, hay un botón de audio
  final List<String> options;
  final int answer;
  final String explanation;
  const Question(
      this.prompt, this.speakText, this.options, this.answer, this.explanation);
}

List<String> _options(String correct, List<String> pool, Random r) {
  final others = pool.where((e) => e != correct).toSet().toList()..shuffle(r);
  final opts = [correct, ...others.take(3)]..shuffle(r);
  return opts;
}

List<Question> buildQuiz({int count = 10}) {
  final r = Random();
  final allPast = verbs.map((v) => v.past).toList();
  final allEs = verbs.map((v) => v.es).toList();
  final allForms =
      verbs.expand((v) => v.examples).map((e) => e.form).toList();

  final questions = <Question>[];
  for (var i = 0; i < count; i++) {
    final v = verbs[r.nextInt(verbs.length)];
    switch (i % 4) {
      case 0:
        final opts = _options(v.past, allPast, r);
        questions.add(Question(
            '¿Cuál es el pasado de “${v.base}”?',
            null,
            opts,
            opts.indexOf(v.past),
            '${v.base} → ${v.past} → ${v.participle}'));
        break;
      case 1:
        final opts = _options(v.es, allEs, r);
        questions.add(Question('¿Qué significa “${v.base}”?', null, opts,
            opts.indexOf(v.es), '${v.base} = ${v.es}'));
        break;
      case 2:
        final ex = v.examples[r.nextInt(v.examples.length)];
        final opts = _options(ex.form, allForms, r);
        questions.add(Question(
            'Completa la oración:\n\n${ex.blank}\n\n(${ex.es})',
            null,
            opts,
            opts.indexOf(ex.form),
            ex.en));
        break;
      default:
        final opts = _options(v.es, allEs, r);
        questions.add(Question('Escucha y elige el significado.', v.base, opts,
            opts.indexOf(v.es), '${v.base} = ${v.es}'));
    }
  }
  return questions;
}
