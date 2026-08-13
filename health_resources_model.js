export const HEALTH_RESOURCES_MODEL = Object.freeze({
  modelId: 'health_resources_model',
  assessmentId: 'resource',
  modelVersion: '1.1',
  instrumentVersion: 1,
  calculationVersion: 'resource-assessment-70-v1',
  primaryLanguage: 'es-MX',
  supportedLanguages: Object.freeze(['es-MX', 'en-US']),
  questionCount: 70,
  scale: Object.freeze({ min: 0, max: 5, direction: 'higher_is_more_resource_deficit' }),
});

export const HEALTH_RESOURCE_DOMAINS = Object.freeze([
  {
    code: 'physical',
    resultCode: 'r_phys',
    questionCodes: ['T1', 'T2', 'T3', 'T4'],
    title: { 'es-MX': 'Recursos físicos', 'en-US': 'Physical resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida el organismo conserva su capacidad de funcionar y recuperarse ante las exigencias de la vida?',
      'en-US': 'To what extent does the body retain its ability to function and recover under life demands?',
    },
  },
  {
    code: 'psychological',
    resultCode: 'r_psych',
    questionCodes: ['M1', 'M2', 'M3', 'M4'],
    title: { 'es-MX': 'Recursos psicológicos', 'en-US': 'Psychological resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida la persona conserva su estabilidad psicológica ante las exigencias de la vida?',
      'en-US': 'To what extent does the person retain psychological stability under life demands?',
    },
  },
  {
    code: 'social',
    resultCode: 'r_social',
    questionCodes: ['C1', 'C2', 'C3'],
    title: { 'es-MX': 'Recursos sociales', 'en-US': 'Social resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida la persona evita enfrentar sola las exigencias críticas de la vida?',
      'en-US': 'To what extent is the person not left alone when facing critical life demands?',
    },
  },
  {
    code: 'goal',
    resultCode: 'r_goal',
    questionCodes: ['G1', 'G2', 'G3', 'G12'],
    title: { 'es-MX': 'Recursos de propósito y metas', 'en-US': 'Goal resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida la persona mantiene la dirección hacia sus metas ante las exigencias de la vida?',
      'en-US': 'To what extent does the person maintain direction toward goals under life demands?',
    },
  },
  {
    code: 'financial',
    resultCode: 'r_fin',
    questionCodes: ['F1', 'F2', 'F3', 'F4'],
    title: { 'es-MX': 'Recursos financieros', 'en-US': 'Financial resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida las restricciones financieras evitan controlar la vida de la persona cuando surgen dificultades?',
      'en-US': 'To what extent do financial constraints avoid taking control of a person’s life when difficulties arise?',
    },
  },
  {
    code: 'spiritual',
    resultCode: 'r_spiritual',
    questionCodes: ['P1', 'P2', 'P3'],
    title: { 'es-MX': 'Recursos de integridad y valores', 'en-US': 'Spiritual resources' },
    researchQuestion: {
      'es-MX': '¿En qué medida la persona conserva su integridad interna ante las exigencias de la vida?',
      'en-US': 'To what extent does the person preserve inner integrity under life demands?',
    },
  },
]);

const q = (questionId, code, domain, promptEs, promptEn, optionsEs, optionsEn) => Object.freeze({
  questionId,
  code,
  version: 1,
  domain,
  type: 'single_select',
  scoreDirection: 'higher_is_more_resource_deficit',
  prompt: Object.freeze({ 'es-MX': promptEs, 'en-US': promptEn }),
  options: Object.freeze(optionsEs.map((text, value) => Object.freeze({
    value,
    text: Object.freeze({ 'es-MX': text, 'en-US': optionsEn[value] }),
  }))),
});

const qv = (questionId, code, domain, scoreDirection, promptEs, promptEn, options) => Object.freeze({
  questionId,
  code,
  version: 1,
  domain,
  type: 'single_select',
  scoreDirection,
  prompt: Object.freeze({ 'es-MX': promptEs, 'en-US': promptEn }),
  options: Object.freeze(options.map(([value, textEs, textEn]) => Object.freeze({
    value,
    text: Object.freeze({ 'es-MX': textEs, 'en-US': textEn }),
  }))),
});

const qn = (questionId, code, domain, promptEs, promptEn, unit, constraints = {}) => Object.freeze({
  questionId,
  code,
  version: 1,
  domain,
  type: 'number',
  scoreDirection: 'requires_baseline_normalization',
  prompt: Object.freeze({ 'es-MX': promptEs, 'en-US': promptEn }),
  unit,
  constraints: Object.freeze(constraints),
  options: Object.freeze([]),
});

const scale = (es, en, values = [0, 1, 2, 3, 4, 5]) =>
  values.map((value, index) => [value, es[index], en[index]]);

export const HEALTH_RESOURCE_QUESTIONS = Object.freeze([
  q('11111111-0000-4000-8000-000000000087', 'T1', 'physical',
    'Después de la carga habitual de su actividad principal, ¿cuánta energía física suele quedarle?',
    'After the usual demands of your main activity, how much physical energy do you usually have left?',
    ['Me queda mucha energía y tolero la carga con facilidad', 'Por lo general tengo suficiente energía', 'Me alcanza la energía, pero con poca reserva', 'Con frecuencia tengo que funcionar casi al límite', 'Regularmente me falta energía física', 'Mi organismo claramente no logra responder a las exigencias de la actividad'],
    ['I have plenty of energy left and tolerate the demands easily', 'I usually have enough energy', 'I have enough energy, but little reserve', 'I often have to function close to my limit', 'I regularly lack physical energy', 'My body clearly cannot meet the demands of the activity']),
  q('11111111-0000-4000-8000-000000000088', 'T2', 'physical',
    '¿Con qué frecuencia realiza actividad física que ayuda a mantener su cuerpo en condiciones funcionales?',
    'How often do you engage in physical activity that helps keep your body functional?',
    ['4 o más veces por semana', '2–3 veces por semana', 'Aproximadamente una vez por semana', 'De manera ocasional', 'Casi nunca', 'Nunca'],
    ['4 or more times per week', '2–3 times per week', 'About once per week', 'Occasionally', 'Almost never', 'Never']),
  q('11111111-0000-4000-8000-000000000089', 'T3', 'physical',
    '¿Durante cuánto tiempo suele mantener su actividad física habitual sin presentar un agotamiento marcado?',
    'How long can you usually maintain your normal physical activity without marked exhaustion?',
    ['Durante mucho tiempo; mi resistencia es alta', 'Durante bastante tiempo; mi resistencia es buena', 'Un tiempo moderado', 'Me canso rápidamente', 'Me canso muy rápidamente', 'Incluso una carga pequeña me agota'],
    ['For a long time; my endurance is high', 'For quite a long time; my endurance is good', 'For a moderate amount of time', 'I tire quickly', 'I tire very quickly', 'Even a small amount of exertion exhausts me']),
  q('11111111-0000-4000-8000-000000000090', 'T4', 'physical',
    'Cuando se ha cansado físicamente, se ha enfermado o ha pasado por una carga mayor, ¿qué tan rápido suele recuperar su nivel habitual de energía?',
    'When you have been physically tired, ill, or under increased strain, how quickly does your body usually return to its normal energy level?',
    ['Rápidamente, en 1–2 días', 'Por lo general, en 3–4 días', 'Aproximadamente en una semana', 'Hasta dos semanas', 'Un mes o más', 'Prácticamente no me recupero'],
    ['Quickly, within 1–2 days', 'Usually within 3–4 days', 'In about one week', 'Up to two weeks', 'One month or more', 'I practically do not recover']),

  q('11111111-0000-4000-8000-000000000091', 'M1', 'psychological',
    'Cuando atraviesa un momento difícil, ¿qué suele ayudarle a recuperar el equilibrio interno y afrontar su estado?',
    'When you are going through a difficult time, what usually helps you regain inner balance and cope with your state?',
    ['Tengo varias estrategias, incluida la ayuda profesional', 'Tengo estrategias que funcionan', 'Tengo estrategias, pero las uso de manera irregular', 'Tengo pocas estrategias y no siempre ayudan', 'En realidad solo tengo una forma de distraerme o esperar a que pase', 'No hago nada de manera intencional; simplemente aguanto'],
    ['I have several strategies, including professional support', 'I have strategies that work', 'I have strategies, but use them irregularly', 'I have few strategies and they do not always help', 'I essentially have only one way to distract myself or wait it out', 'I do nothing intentionally; I simply endure it']),
  q('11111111-0000-4000-8000-000000000092', 'M2', 'psychological',
    '¿En qué medida su experiencia de vida previa le ayuda a afrontar situaciones difíciles en la actualidad?',
    'To what extent does your previous life experience help you cope with difficult situations today?',
    ['Mi experiencia previa me ayuda a mantener la estabilidad y encontrar soluciones', 'Por lo general, mi experiencia previa me ayuda a afrontar las dificultades', 'A veces ayuda y a veces no', 'Ayuda poco', 'Mi experiencia previa más bien dificulta las cosas o me recuerda experiencias dolorosas', 'A pesar de mi experiencia previa, en situaciones difíciles me siento sin recursos'],
    ['My previous experience helps me remain stable and find solutions', 'My previous experience usually helps me cope with difficulties', 'Sometimes it helps and sometimes it does not', 'It helps little', 'My previous experience tends to hinder me or bring back painful experiences', 'Despite my previous experience, I feel helpless in difficult situations']),
  q('11111111-0000-4000-8000-000000000093', 'M3', 'psychological',
    'Cuando las circunstancias cambian y la forma habitual de resolver un problema deja de funcionar, ¿qué tan fácil le resulta encontrar un enfoque nuevo y adaptarse?',
    'When circumstances change and your usual way of solving a problem no longer works, how easily can you find a new approach and adapt?',
    ['Me reajusto con facilidad', 'Por lo general necesito poco tiempo', 'Me reajusto, pero con un esfuerzo considerable', 'Me resisto al cambio, aunque puedo adaptarme', 'Me resulta muy difícil reajustarme', 'Prácticamente no puedo adaptarme a los cambios'],
    ['I readjust easily', 'I usually need a little time', 'I readjust, but with considerable effort', 'I resist change, but can adapt', 'It is very difficult for me to readjust', 'I am practically unable to adapt to change']),
  q('11111111-0000-4000-8000-000000000094', 'M4', 'psychological',
    '¿Qué tan pronto suele notar que está cansado(a), sobrecargado(a), comenzando a agotarse o dejando de afrontar adecuadamente la situación?',
    'How soon do you usually notice that you are tired, overloaded, beginning to burn out, or no longer coping effectively?',
    ['Lo noto pronto y normalmente hago algún cambio', 'Lo noto, aunque no de inmediato', 'Me doy cuenta solo cuando ya se ha vuelto difícil', 'Con frecuencia me entero por otras personas', 'Me doy cuenta solo cuando ocurre una crisis o quiebre', 'Por lo general no lo noto o lo niego hasta el final'],
    ['I notice it early and usually make a change', 'I notice it, but not immediately', 'I realize it only when things have already become difficult', 'I often learn it from other people', 'I realize it only when a breakdown occurs', 'I usually do not notice it or deny it until the very end']),

  q('11111111-0000-4000-8000-000000000109', 'C1', 'social',
    'Si ocurriera una crisis grave en su vida, ¿a cuántas personas podría llamar realmente para pedir ayuda?',
    'If a serious crisis occurred in your life, how many people could you genuinely call and ask for help?',
    ['3 o más', '2 personas', '1 persona', 'Hay personas, pero no estoy seguro(a)', 'Formalmente hay personas, pero no acudiría a ellas', 'A nadie'],
    ['3 or more', '2 people', '1 person', 'There are people, but I am not sure', 'There are technically people, but I would not turn to them', 'No one']),
  q('11111111-0000-4000-8000-000000000110', 'C2', 'social',
    '¿Hay alguien en su vida con quien pueda hablar con total honestidad sobre sus preocupaciones, errores y dificultades?',
    'Is there someone in your life with whom you can be completely honest about your worries, mistakes, and difficulties?',
    ['Sí, hay una persona y la relación es estable', 'Hay una persona, pero no puedo hablar de todos los temas', 'Hay personas a quienes puedo confiar parte de lo que vivo', 'Antes había una persona así, pero ahora no', 'A veces quisiera hablar con franqueza, pero no tengo con quién', 'No hay nadie con quien pueda ser completamente honesto(a)'],
    ['Yes, there is someone and the relationship is stable', 'There is someone, but not for every topic', 'There are people I can trust with part of what I am going through', 'I used to have someone like that, but not now', 'Sometimes I want to speak openly, but have no one to talk to', 'There is no one with whom I can be completely honest']),
  q('11111111-0000-4000-8000-000000000111', 'C3', 'social',
    'Si realmente necesitara ayuda, ¿qué tan fácil le resultaría pedirla?',
    'If you truly needed help, how easy would it be for you to ask for it?',
    ['Pediría ayuda con facilidad si la necesitara', 'Normalmente puedo pedirla, aunque a veces me resulta incómodo', 'Solo pido ayuda en situaciones verdaderamente importantes', 'Me resulta difícil pedir ayuda', 'Solo la pido cuando ya no puedo afrontar la situación', 'Prácticamente no puedo pedir ayuda, incluso cuando la necesito'],
    ['I would ask for help easily if I needed it', 'I can usually ask, although it is sometimes uncomfortable', 'I ask for help only in truly important situations', 'It is difficult for me to ask for help', 'I ask only when I can no longer cope', 'I am practically unable to ask for help, even when I need it']),

  q('11111111-0000-4000-8000-000000000095', 'G1', 'goal',
    '¿Qué tan claramente comprende adónde quiere llegar durante los próximos años?',
    'How clearly do you understand where you want to be in the next few years?',
    ['Lo comprendo con mucha claridad y tengo una dirección concreta', 'En general comprendo la dirección, aunque aún no defino los detalles', 'Tengo una idea general, pero la meta es poco clara', 'Formalmente tengo metas, pero casi no me motivan', 'En este momento no comprendo hacia dónde quiero avanzar', 'No veo una dirección clara para mí y siento que estoy en un callejón sin salida'],
    ['I understand it very clearly and have a specific direction', 'I generally understand the direction, although the details are not yet defined', 'I have a general idea, but the goal is vague', 'I technically have goals, but they barely motivate me', 'At present I do not understand where I want to go', 'I do not see a clear direction for myself and feel stuck']),
  q('11111111-0000-4000-8000-000000000096', 'G2', 'goal',
    '¿En qué medida su actividad actual le ayuda a avanzar hacia el futuro que desea para usted?',
    'To what extent does your current activity help you move toward the future you want for yourself?',
    ['Me ayuda por completo', 'Me ayuda en gran medida', 'Me ayuda solo parcialmente', 'Me ayuda poco', 'Casi no me ayuda, pero por ahora tengo que seguir haciéndola', 'Más bien me aleja del futuro que deseo'],
    ['It helps completely', 'It mostly helps', 'It helps only partially', 'It helps little', 'It hardly helps, but for now I have to keep doing it', 'It tends to move me away from the future I want']),
  q('11111111-0000-4000-8000-000000000097', 'G3', 'goal',
    '¿En qué medida suele lograr avanzar de manera constante hacia las metas que son importantes para usted?',
    'To what extent are you usually able to move consistently toward goals that are important to you?',
    ['Normalmente avanzo con seguridad y ajusto el camino cuando es necesario', 'En general logro mantener la dirección', 'A veces pierdo el rumbo, pero regreso a mis metas', 'Con frecuencia me distraigo o cambio de dirección', 'Me resulta difícil sostener el avance hacia metas importantes', 'Normalmente vivo según las circunstancias del momento y casi no avanzo hacia mis metas'],
    ['I usually move forward confidently and adjust course when needed', 'I generally manage to maintain direction', 'Sometimes I lose direction, but return to my goals', 'I often become distracted or change direction', 'It is difficult for me to sustain progress toward important goals', 'I usually live according to immediate circumstances and make almost no progress toward my goals']),

  q('11111111-0000-4000-8000-000000000112', 'F1', 'financial',
    'Si hoy desapareciera su principal fuente de ingresos, ¿durante cuánto tiempo alcanzarían sus reservas financieras actuales?',
    'If your primary income disappeared today, how long would your current financial reserves last?',
    ['Más de 6 meses', 'De 3 a 6 meses', 'De 1 a 3 meses', 'De 2 a 4 semanas', 'Unos cuantos días', 'No tengo reservas o ya vivo endeudado(a)'],
    ['More than 6 months', '3–6 months', '1–3 months', '2–4 weeks', 'A few days', 'I have no reserves or already live in debt']),
  q('11111111-0000-4000-8000-000000000113', 'F2', 'financial',
    '¿Qué proporción de sus ingresos mensuales se destina a créditos, deudas, pensión alimenticia, colegiaturas u otras obligaciones financieras?',
    'What proportion of your monthly income goes to loans, debts, child or spousal support, tuition, or other financial obligations?',
    ['No tengo deudas ni obligaciones de este tipo', 'Hasta 15%', '15–30%', '30–50%', '50–70%', 'Más de 70%'],
    ['I have no debts or obligations of this kind', 'Up to 15%', '15–30%', '30–50%', '50–70%', 'More than 70%']),
  q('11111111-0000-4000-8000-000000000114', 'F3', 'financial',
    '¿Qué tan estables fueron sus ingresos durante el último año?',
    'How stable was your income during the past year?',
    ['Estables y en aumento', 'Estables', 'Mayormente estables, con algunas variaciones', 'Inestables y con cambios frecuentes', 'Inestables y en disminución', 'No tengo ingresos o son críticamente insuficientes'],
    ['Stable and increasing', 'Stable', 'Mostly stable, with some fluctuations', 'Unstable and frequently changing', 'Unstable and decreasing', 'No income or critically insufficient income']),
  q('11111111-0000-4000-8000-000000000115', 'F4', 'financial',
    '¿Qué tan bien comprende normalmente su situación financiera y puede planear sus gastos?',
    'How well do you usually understand your financial situation and plan your expenses?',
    ['Comprendo bien mis finanzas y puedo planear el futuro', 'En general comprendo bien mis ingresos y gastos', 'Tengo una comprensión general de mi situación financiera', 'Con frecuencia no tengo claridad sobre en qué se va el dinero', 'Normalmente vivo de un ingreso al siguiente', 'Prácticamente no controlo ni comprendo mi situación financiera'],
    ['I understand my finances well and can plan for the future', 'I generally understand my income and expenses well', 'I have a general understanding of my financial situation', 'I often do not know where the money goes', 'I usually live from one payment to the next', 'I practically do not control or understand my financial situation']),

  q('11111111-0000-4000-8000-000000000116', 'P1', 'spiritual',
    '¿Qué tan claramente comprende lo que realmente es importante para usted en la vida?',
    'How clearly do you understand what is truly important to you in life?',
    ['Lo comprendo con mucha claridad y mis valores son estables', 'En general lo comprendo, aunque no siempre reflexiono sobre ello', 'Comprendo solo una parte de mis valores', 'Tengo algunas ideas, pero son poco claras', 'En este momento no comprendo qué es realmente importante para mí', 'Con frecuencia siento que lo que ocurre carece de sentido'],
    ['I understand it very clearly and my values are stable', 'I generally understand it, although I do not always reflect on it', 'I understand only part of my values', 'I have some ideas, but they are vague', 'At present I do not understand what is truly important to me', 'I often feel that what is happening is meaningless']),
  q('11111111-0000-4000-8000-000000000117', 'P2', 'spiritual',
    '¿Cuenta con prácticas o estrategias que le ayuden a conservar su estabilidad interna durante periodos difíciles?',
    'Do you have practices or strategies that help you preserve inner stability during difficult periods?',
    ['Sí, tengo estrategias regulares y eficaces', 'Sí, aunque las uso de manera irregular', 'A veces utilizo algunas estrategias', 'Rara vez hago algo de manera intencional para sostenerme', 'No conozco estrategias que me ayuden a conservar el equilibrio interno', 'Normalmente utilizo estrategias que tienden a perjudicarme más que a ayudarme'],
    ['Yes, I have regular and effective strategies', 'Yes, but I use them irregularly', 'Sometimes I use certain strategies', 'I rarely do anything intentionally to support myself', 'I do not know strategies that help me preserve inner balance', 'I usually use strategies that tend to harm rather than help me']),
  q('11111111-0000-4000-8000-000000000118', 'P3', 'spiritual',
    '¿En qué medida sus acciones reales corresponden con aquello que considera correcto e importante?',
    'To what extent do your actual actions align with what you consider right and important?',
    ['Corresponden casi por completo', 'Corresponden en gran medida', 'Corresponden solo parcialmente', 'Con frecuencia tengo que actuar de otra manera', 'Normalmente actúo en contra de mis convicciones', 'Vivo en una contradicción clara con lo que considero correcto'],
    ['They align almost completely', 'They mostly align', 'They align only partially', 'I often have to act differently', 'I usually act against my convictions', 'I live in clear contradiction with what I consider right']),

  qv('11111111-0000-4000-8000-000000000107', 'G12', 'goal_resource', 'higher_is_more_resource_deficit',
    '¿Qué tan claramente comprende para qué está superando actualmente las principales dificultades de su vida?',
    'How clearly do you understand what you are currently overcoming the main difficulties in your life for?',
    scale(
      ['Lo comprendo con mucha claridad', 'Más bien lo comprendo', 'Lo comprendo parcialmente', 'Dudo con frecuencia', 'Rara vez lo comprendo', 'Prácticamente no encuentro sentido en estos esfuerzos'],
      ['I understand it very clearly', 'I mostly understand it', 'I understand it partially', 'I often have doubts', 'I rarely understand it', 'I see practically no meaning in these efforts'])),

  qv('11111111-0000-4000-8000-000000000044', 'RE1', 'recovery', 'higher_is_more_risk',
    'Después de descansar, de un fin de semana o de un periodo en el que disminuye la carga:',
    'After rest, a weekend, or a period when the demands decrease:',
    scale(
      ['Por lo general, mi energía y mi estado regresan bastante rápido a su nivel habitual', 'La mayoría de las veces me siento notablemente mejor', 'A veces recuperarme toma más tiempo del que quisiera', 'Incluso después de descansar permanece parte del cansancio o la tensión', 'Cada vez me cuesta más sentir que realmente me he recuperado', 'Incluso cuando disminuye la carga, mi estado casi no mejora'],
      ['My energy and condition usually return to their normal level fairly quickly', 'Most of the time I feel noticeably better', 'Sometimes recovery takes longer than I would like', 'Even after rest, some fatigue or tension remains', 'It is increasingly difficult for me to feel truly recovered', 'Even when the demands decrease, my condition hardly improves'])),
  qv('11111111-0000-4000-8000-000000000045', 'RE2', 'recovery', 'higher_is_more_risk',
    'Si un periodo de mayor carga dura más de lo que esperaba:',
    'If a period of increased demands lasts longer than you expected:',
    scale(
      ['Por lo general logro recuperarme sobre la marcha', 'La mayoría de las veces lo afronto sin consecuencias graves', 'Con el tiempo empiezo a notar cansancio acumulado', 'Después de una carga prolongada necesito bastante más tiempo para recuperarme', 'Cuanto más dura la carga, más difícil me resulta volver a mi estado habitual', 'A veces siento que el cansancio se acumula más rápido de lo que alcanzo a recuperarme'],
      ['I can usually recover as I go', 'Most of the time I cope without serious consequences', 'Over time I begin to notice accumulated fatigue', 'After prolonged demands I need noticeably more time to recover', 'The longer the demands continue, the harder it is to return to my usual state', 'Sometimes fatigue seems to accumulate faster than I can recover'])),

  qv('11111111-0000-4000-8000-000000000015', 'PR1', 'psych', 'higher_is_more_risk',
    'Cuando está muy alterado(a), irritado(a), dolido(a) o ansioso(a):',
    'When you are very upset, irritated, hurt, or anxious:',
    scale(
      ['Por lo general esto no me impide evaluar la situación con calma', 'A veces se vuelve un poco más difícil ver la situación objetivamente', 'En esos momentos tengo que hacer un esfuerzo consciente para controlarme', 'Las emociones intensas con frecuencia me impiden evaluar con calma lo que ocurre', 'Me resulta difícil separar lo que siento de la situación misma', 'En esos momentos, lo que siento determina casi por completo cómo percibo la situación'],
      ['This usually does not prevent me from assessing the situation calmly', 'Sometimes it becomes a little harder to view the situation objectively', 'At those times I have to make a conscious effort to compose myself', 'Strong emotions often prevent me from calmly assessing what is happening', 'It is difficult for me to separate my feelings from the situation itself', 'At those times my feelings almost completely determine how I perceive the situation'])),
  qv('11111111-0000-4000-8000-000000000016', 'PR2', 'psych', 'higher_is_more_risk',
    'Si las circunstancias no resultan como esperaba:',
    'If circumstances do not turn out as you expected:',
    scale(
      ['Por lo general acepto estos cambios con calma', 'Es desagradable, pero se me pasa bastante rápido', 'Durante un tiempo me preocupo y me siento mal por ello', 'Estos cambios con frecuencia me desestabilizan y afectan mi ánimo durante mucho tiempo', 'Me resulta muy difícil aceptar que las cosas no salieron como esperaba', 'Cuando tengo que cambiar de planes, puedo pasar mucho tiempo enojado(a), preocupado(a) o inquieto(a)'],
      ['I usually accept such changes calmly', 'It is unpleasant, but passes fairly quickly', 'For a while I worry and feel upset about it', 'Such changes often throw me off balance and affect my mood for a long time', 'It is very hard for me to accept that things did not go as expected', 'When I have to change plans, I may remain angry, worried, or restless for a long time'])),
  qv('11111111-0000-4000-8000-000000000017', 'PR3', 'psych', 'higher_is_more_risk',
    'Cuando durante mucho tiempo tiene que hacer algo desagradable, difícil o agotador, pero necesario:',
    'When for a long time you have to do something unpleasant, difficult, or tiring, but necessary:',
    scale(
      ['Por lo general puedo continuar con calma el tiempo que sea necesario', 'Me cansa, pero normalmente no provoca una tensión interna intensa', 'Con el tiempo me canso notablemente y pienso cada vez más en cuándo terminará', 'Con frecuencia siento irritación, cansancio o deseos de abandonar todo', 'Me resulta muy difícil obligarme a continuar, aunque comprenda que es necesario', 'En algún momento siento que ya no puedo soportarlo y quiero detenerlo a cualquier precio'],
      ['I can usually continue calmly for as long as necessary', 'It is tiring, but usually does not cause intense inner tension', 'Over time I become noticeably tired and increasingly think about when it will end', 'I often feel irritated, tired, or want to abandon everything', 'It becomes very hard to make myself continue, even though I understand it is necessary', 'At some point I feel I cannot endure it any longer and want to stop at any cost'])),
  qv('11111111-0000-4000-8000-000000000018', 'PR4', 'psych', 'higher_is_more_risk',
    'Cuando es imposible saber de antemano cómo terminará todo:',
    'When it is impossible to know in advance how everything will turn out:',
    scale(
      ['Por lo general puedo vivir y actuar con calma aunque todavía no conozca el resultado', 'La incertidumbre me preocupa un poco, pero rara vez me impide actuar', 'A veces empiezo a preocuparme notablemente porque no sé qué ocurrirá', 'Me resulta difícil tranquilizarme hasta que la situación se aclare', 'Esta incertidumbre me agota mucho y vuelve constantemente a mis pensamientos', 'Cuando no sé cómo terminará todo, la preocupación puede absorberme tanto que me cuesta pensar en otra cosa'],
      ['I can usually live and act calmly even when the outcome is not yet known', 'Uncertainty worries me a little, but rarely gets in the way', 'Sometimes I become noticeably worried because I do not know what will happen next', 'It is hard for me to calm down until the situation becomes clear', 'Such uncertainty exhausts me and constantly returns to my thoughts', 'When I do not know how things will turn out, worry can absorb me so much that it is difficult to think about anything else'])),
  qv('11111111-0000-4000-8000-000000000019', 'PR5', 'psych', 'higher_is_more_risk',
    'Cuando queda claro que el método elegido no funciona:',
    'When it becomes clear that the chosen approach is not working:',
    scale(
      ['Por lo general lo acepto con calma y cambio a otra cosa', 'Es desagradable, pero normalmente no provoca una resistencia interna intensa', 'Necesito algo de tiempo para aceptar que debo cambiar algo', 'Me cuesta abandonar una forma habitual de actuar', 'La necesidad de cambiar mi manera habitual de actuar suele provocarme una fuerte tensión interna', 'Aunque comprenda que el método anterior ya no funciona, me resulta muy difícil abandonarlo'],
      ['I usually accept it calmly and switch to something else', 'It is unpleasant, but usually does not cause strong inner resistance', 'I need some time to accept the need to change something', 'It can be hard for me to give up a familiar way of acting', 'The need to change my usual approach often causes strong inner tension', 'Even when I understand that the previous approach no longer works, it is very difficult for me to give it up'])),
  qv('11111111-0000-4000-8000-000000000020', 'PR6', 'psych', 'higher_is_more_risk',
    'Si se esfuerza, pero durante mucho tiempo no ve resultados:',
    'If you are making an effort but do not see results for a long time:',
    scale(
      ['Por lo general puedo continuar con calma y sin mucha tensión', 'Me desanima, pero normalmente no me impide seguir adelante', 'A veces empiezo a dudar si vale la pena continuar', 'Cada vez me resulta más difícil conservar la paciencia y la motivación', 'Esto me irrita o me desanima mucho', 'Si el resultado tarda mucho en aparecer, me resulta muy difícil continuar y quiero abandonar todo'],
      ['I can usually continue calmly and without much tension', 'It upsets me, but usually does not prevent me from moving forward', 'Sometimes I begin to doubt whether it is worth continuing', 'It becomes increasingly difficult to maintain patience and motivation', 'This greatly irritates or upsets me', 'If the result does not appear for a long time, it becomes very hard to continue and I want to give up'])),

  qv('11111111-0000-4000-8000-000000000021', 'SR1', 'social', 'higher_is_more_risk',
    'Cuando surge un problema importante o una situación difícil:',
    'When an important problem or difficult situation arises:',
    scale(
      ['Por lo general veo varias opciones posibles para actuar', 'La mayoría de las veces puedo elegir entre varias opciones', 'A veces siento que no hay muchas opciones buenas', 'Con frecuencia solo veo una o dos salidas posibles', 'Rara vez se me ocurre más de una forma de actuar', 'Por lo general siento que prácticamente no tengo opciones'],
      ['I usually see several possible courses of action', 'Most of the time I can choose from several options', 'Sometimes it seems there are not many good options', 'I often see only one or two possible ways out', 'I rarely think of more than one course of action', 'It usually seems that I have practically no choice'])),
  qv('11111111-0000-4000-8000-000000000022', 'SR2', 'social', 'higher_is_more_risk',
    'Cuando va a hacer algo a su manera:',
    'When you are going to do something your own way:',
    scale(
      ['Por lo general hago lo que considero necesario', 'A veces tomo en cuenta la posible reacción de otras personas', 'Con frecuencia pienso de antemano cómo reaccionarán los demás', 'A menudo renuncio a mis planes para evitar el descontento o los conflictos', 'Me cuesta hacer lo que considero correcto si puede desagradarle a alguien', 'Muy a menudo es más fácil renunciar a mis planes que afrontar las consecuencias para mis relaciones'],
      ['I usually do what I consider necessary', 'Sometimes I consider how other people may react', 'I often think in advance about how others will respond', 'I often give up my plans to avoid disapproval or conflict', 'It can be hard to do what I consider right if someone may dislike it', 'Very often it is easier to give up my plans than deal with the consequences for relationships with other people'])),
  qv('11111111-0000-4000-8000-000000000023', 'SR3', 'social', 'higher_is_more_risk',
    'Cuando otras personas le dicen que en su situación no hay motivo para preocuparse:',
    'When other people tell you there is nothing to worry about in your situation:',
    scale(
      ['Por lo general intento comprender por mí mismo(a) los posibles riesgos', 'La opinión de los demás es importante, pero intento formar la mía', 'A veces me cuesta saber si realmente debería preocuparme', 'Con frecuencia me tranquilizo solo porque otras personas dicen que todo está bien', 'Me cuesta no depender de la opinión de los demás sobre qué tan segura es la situación', 'Si personas cercanas o con autoridad dicen que todo está bien, normalmente dejo de pensar en los posibles riesgos'],
      ['I usually still try to understand the possible risks for myself', 'Other people’s opinions matter, but I try to form my own', 'Sometimes it is difficult to know whether I should really be concerned', 'I often calm down only because others say everything is fine', 'It is hard not to rely on others’ opinions about how safe the situation is', 'If people close to me or authority figures say everything is fine, I usually stop thinking about possible risks'])),
  qv('11111111-0000-4000-8000-000000000024', 'SR4', 'social', 'higher_is_more_risk',
    'Cuando hace planes para el futuro o piensa en cosas importantes para usted:',
    'When you make plans for the future or think about things that are important to you:',
    scale(
      ['Por lo general comprendo bien lo que yo quiero', 'A veces tomo en cuenta las expectativas de otras personas, pero tengo claros mis propios deseos', 'A veces cuesta distinguir lo que quiero yo de lo que esperan los demás', 'Con frecuencia noto que me guío por las expectativas ajenas más de lo que quisiera', 'A menudo me cuesta comprender qué quiero yo realmente', 'A veces siento que vivo más según las expectativas de otros que según mis propios deseos y metas'],
      ['I usually understand well what I want', 'Sometimes I consider other people’s expectations, but my own wishes are clear to me', 'It can be difficult to distinguish what I want from what others expect', 'I often notice that I follow others’ expectations more than I would like', 'It is often difficult for me to understand what I want', 'Sometimes it seems that I live more by other people’s expectations than by my own wishes and goals'])),

  qv('11111111-0000-4000-8000-000000000008', 'MG1', 'goals', 'higher_is_more_goal_alignment',
    'Si observa sus acciones recientes, ¿en qué medida le ayudan a acercarse a su meta más importante?',
    'Looking at your recent actions, to what extent do they help you move closer to your most important goal?',
    scale(
      ['No tengo una meta así', 'Confío en que con el tiempo todo se resolverá por sí solo', 'Ahora toda mi energía se destina a asuntos y problemas inmediatos', 'Algunas de mis decisiones me ayudan a acercarme a esa meta', 'Muchas decisiones importantes están relacionadas con esa meta', 'Casi todo lo importante que hago me ayuda a acercarme a esa meta'],
      ['I do not have such a goal', 'I expect that in time everything will work itself out', 'Right now all my energy goes to immediate matters and problems', 'Some of my decisions help me move closer to this goal', 'Many important decisions are connected with this goal', 'Almost everything important that I do helps me move closer to this goal'])),
  qv('11111111-0000-4000-8000-000000000009', 'MG2', 'goals', 'higher_is_more_priority_clarity',
    'Si dos asuntos importantes para usted requieren decisiones diferentes (por ejemplo, salud y dinero, familia y trabajo, descanso y resultados, seguridad y nuevas oportunidades):',
    'If two matters important to you require different decisions (for example, health and money, family and work, rest and results, safety and new opportunities):',
    scale(
      ['Por lo general elijo lo que es más fácil o causa menos problemas ahora', 'Con frecuencia pospongo la decisión durante mucho tiempo e intento no elegir nada', 'Intento conservarlo todo a la vez, aunque resulte difícil', 'Por lo general elijo lo que considero más importante en ese momento', 'Puedo renunciar a lo menos importante en favor de lo más importante', 'Por lo general comprendo bastante bien a qué estoy dispuesto(a) a renunciar por lo que realmente importa'],
      ['I usually choose what is easier or causes fewer problems right now', 'I often postpone the decision for a long time and try not to choose anything', 'I try to keep everything at once, even when it becomes difficult', 'I usually choose what I consider more important at that moment', 'I can give up what is less important for what is more important', 'I usually understand quite well what I am willing to sacrifice for what truly matters'])),
  qv('11111111-0000-4000-8000-000000000010', 'MG3', 'goals', 'higher_is_more_conflict',
    'Cuando tiene que resolver al mismo tiempo varios asuntos importantes para usted:',
    'When several matters important to you have to be addressed at the same time:',
    scale(
      ['Esto rara vez ocurre', 'A veces genera inconvenientes', 'Periódicamente tengo que posponer algo importante', 'Por ello, con frecuencia se perjudica un área importante de mi vida', 'Regularmente pierdo tiempo, energía u oportunidades debido a estos conflictos', 'El conflicto entre metas importantes genera constantemente problemas graves'],
      ['This rarely happens', 'Sometimes it creates inconvenience', 'From time to time I have to postpone something important', 'Because of this, an important area of my life often suffers', 'I regularly lose time, energy, or opportunities because of these conflicts', 'Conflict between important goals constantly creates serious problems'])),
  qv('11111111-0000-4000-8000-000000000011', 'MG4', 'goals', 'higher_is_more_control',
    'Cuando comprende que para alcanzar una meta importante debe cambiar algo en su vida:',
    'When you realize that reaching an important goal requires changing something in your life:',
    scale(
      ['Por lo general no me lo puedo permitir', 'Muy a menudo las circunstancias me impiden actuar como considero necesario', 'A veces tengo que elegir algo que no considero correcto', 'Tengo cierta capacidad de influir en la situación, pero no siempre', 'La mayoría de las veces puedo actuar como considero necesario', 'Por lo general yo mismo(a) decido qué hacer después'],
      ['I usually cannot afford to do so', 'Very often circumstances prevent me from acting as I think I should', 'Sometimes I am forced to choose something I do not consider right', 'I have some ability to influence the situation, but not always', 'Most of the time I can act as I think I should', 'I usually decide for myself what to do next'])),
  qv('11111111-0000-4000-8000-000000000012', 'MG5', 'goals', 'higher_is_more_cost_tolerance',
    'Si alcanzar una meta importante empieza a requerir más tiempo, energía, dinero u otras pérdidas de las que esperaba:',
    'If reaching an important goal begins to require more time, energy, money, or other losses than you expected:',
    scale(
      ['Por lo general abandono esas metas', 'Con frecuencia reduzco mis esfuerzos o pospongo la meta', 'Continúo solo si el costo sigue siendo aceptable', 'Por lo general continúo avanzando a pesar de las dificultades adicionales', 'Estoy dispuesto(a) a soportar inconvenientes importantes por una meta importante', 'Si la meta es realmente importante, estoy dispuesto(a) a continuar incluso con un costo muy alto'],
      ['I usually give up such goals', 'I often reduce my effort or postpone the goal', 'I continue only if the cost remains acceptable', 'I usually continue moving toward the goal despite additional difficulties', 'I am prepared to tolerate serious inconvenience for an important goal', 'If the goal is truly important, I am prepared to continue even at a very high cost'])),
  qv('11111111-0000-4000-8000-000000000013', 'MG6', 'goals', 'higher_is_more_goal_identity',
    '¿Qué tan importante es para usted la meta a la que actualmente dedica más atención?',
    'How important to you is the goal that currently receives most of your attention?',
    scale(
      ['Es solo uno de muchos deseos', 'Es uno de mis planes importantes', 'Es una parte importante de mi vida', 'Es algo por lo que estoy dispuesto(a) a cambiar muchas cosas', 'Es algo sin lo cual me cuesta imaginar mi futuro', 'Es parte de quien soy'],
      ['Just one of many wishes', 'One of my important plans', 'An important part of my life', 'Something for which I am willing to change many things', 'Something without which it is difficult to imagine my future', 'Part of who I am'])),
  qv('11111111-0000-4000-8000-000000000014', 'MG7', 'goals', 'higher_is_more_flexibility',
    'Si queda claro que la meta planteada no puede alcanzarse:',
    'If it becomes clear that a goal cannot be achieved:',
    scale(
      ['Por lo general sigo esperando que todo cambie', 'Me resulta muy difícil abandonar esa meta', 'Sigo avanzando hacia ella durante mucho tiempo, a pesar de todo', 'Durante un tiempo intento encontrar otra manera', 'Por lo general reviso mis planes', 'Si la meta deja de tener sentido, puedo abandonarla y elegir una nueva'],
      ['I usually keep hoping that things will change', 'It is very difficult for me to give up such a goal', 'I continue pursuing it for a long time despite everything', 'For some time I try to find another way', 'I usually revise my plans', 'If the goal no longer makes sense, I can let it go and choose a new one'])),

  qv('11111111-0000-4000-8000-000000000046', 'PEP1', 'expectation', 'higher_is_more_negative_expectation',
    'Cuando ocurre en la vida algo inesperado y no planeado:',
    'When something unexpected and unplanned happens in life:',
    scale(
      ['Por lo general pienso que podré comprender la situación y adaptarme', 'Suelo esperar que todo pueda salir bien, aunque ahora muchas cosas no estén claras', 'Depende de la situación', 'Con frecuencia pienso que los imprevistos pueden crear nuevos problemas', 'Por lo general espero que estos acontecimientos empeoren la situación más de lo que la mejoren', 'Con frecuencia siento que un solo acontecimiento inesperado puede iniciar una cadena de nuevas dificultades'],
      ['I usually think I will be able to understand the situation and adapt to it', 'I tend to expect that things may turn out well even if much is unclear now', 'It varies', 'I often think unexpected events may create new problems', 'I usually expect such events to worsen the situation rather than improve it', 'I often feel that one unexpected event can trigger a chain of new difficulties'])),
  qv('11111111-0000-4000-8000-000000000127', 'V1', 'state_dynamics', 'higher_is_more_negative_velocity',
    'Durante las últimas 2 a 4 semanas, ¿cómo ha cambiado su estado general?',
    'During the past 2–4 weeks, how has your overall condition changed?',
    scale(['Mejoró notablemente', 'Mejoró un poco', 'En general no cambió', 'Empeoró un poco', 'Empeoró notablemente', 'Empeoró de manera brusca'], ['Improved noticeably', 'Improved a little', 'Generally unchanged', 'Worsened a little', 'Worsened noticeably', 'Worsened sharply'])),
  qv('11111111-0000-4000-8000-000000000128', 'V2', 'state_dynamics', 'higher_is_more_resource_exhaustion',
    'Durante las últimas 2 a 4 semanas, ¿qué tanto le ha alcanzado la energía para sus actividades habituales?',
    'During the past 2–4 weeks, how sufficient has your energy been for your usual activities?',
    scale(['Me alcanza bien e incluso me queda reserva', 'En general me alcanza', 'Me alcanza, pero casi sin reserva', 'Con frecuencia tengo que obligarme a seguir', 'Tengo notablemente menos energía de lo habitual', 'Casi no tengo energía ni siquiera para las actividades habituales'], ['It is sufficient and I even have some reserve', 'It is generally sufficient', 'It is sufficient, but with little reserve', 'I often have to make myself continue', 'I have noticeably less energy than usual', 'I have hardly enough energy even for usual activities'])),
  qv('11111111-0000-4000-8000-000000000129', 'V3', 'state_dynamics', 'higher_is_more_recovery_mismatch',
    'Cuando descansa o reduce la carga, ¿qué tanto suele mejorar su estado?',
    'When you rest or reduce the demands, how much better do you usually feel?',
    scale(['Por lo general mejoro notablemente y rápido', 'La mayoría de las veces mejoro', 'A veces ayuda y a veces no', 'Ayuda poco', 'Casi no ayuda', 'Casi nunca aparece la sensación de recuperación'], ['I usually feel noticeably better quite quickly', 'Most of the time I feel better', 'Sometimes it helps and sometimes it does not', 'It helps only a little', 'It hardly helps', 'The feeling of recovery hardly ever comes'])),
  qv('11111111-0000-4000-8000-000000000130', 'V4', 'state_dynamics', 'higher_is_more_recovery_mismatch',
    'Durante las últimas 2 a 4 semanas, después de un día habitual, su estado con mayor frecuencia:',
    'During the past 2–4 weeks, after a usual day your condition has most often:',
    scale(['Se recupera mejor que antes', 'Se recupera un poco mejor', 'Se recupera aproximadamente igual que siempre', 'Se recupera más lentamente', 'Se recupera notablemente peor', 'Casi no se recupera'], ['Recovered better than before', 'Recovered a little better', 'Recovered about the same as usual', 'Recovered more slowly', 'Recovered noticeably worse', 'Hardly recovered at all'])),

  qn('11111111-0000-4000-8000-000000000154', 'K1', 'physical_marker',
    '¿Cuántas horas suele dormir por noche?', 'How many hours do you usually sleep per night?', 'hours', { min: 0, max: 24, step: 0.25, unknownAllowed: false }),
  qn('11111111-0000-4000-8000-000000000155', 'K2', 'physical_marker',
    '¿Cuántas veces suele despertarse durante la noche?', 'How many times do you usually wake up during the night?', 'count', { min: 0, max: 30, step: 1, unknownAllowed: false }),
  qv('11111111-0000-4000-8000-000000000156', 'K3', 'physical_marker', 'higher_is_more_marker_severity',
    '¿Cómo suele sentirse al despertar?', 'How do you usually feel after waking up?',
    scale(['Ligero(a) y con energía', 'Normal', 'Algo pesado(a)', 'Mal; necesito algún estimulante', 'Agotado(a)', 'Prácticamente nunca siento que he dormido lo suficiente'], ['Light and energetic', 'Normal', 'Somewhat sluggish', 'Poor; I need a stimulant', 'Exhausted', 'I practically never feel well rested'])),
  qn('11111111-0000-4000-8000-000000000157', 'K4', 'physical_marker',
    'Si tiene datos de un dispositivo de seguimiento, indique su HRV actual.', 'If you have tracker data, enter your current HRV.', 'ms', { min: 1, max: 500, step: 1, unknownAllowed: true }),
  qn('11111111-0000-4000-8000-000000000158', 'K5', 'physical_marker',
    'Si tiene datos de un dispositivo de seguimiento, indique su frecuencia cardiaca actual en reposo.', 'If you have tracker data, enter your current resting heart rate.', 'bpm', { min: 20, max: 250, step: 1, unknownAllowed: true }),
  qv('11111111-0000-4000-8000-000000000159', 'K6', 'physical_marker', 'higher_is_more_marker_severity',
    '¿Tiene actualmente algún dolor que afecte de manera notable su estado o sus actividades?',
    'Do you currently have pain that noticeably affects your condition or activities?',
    scale(['No', 'Rara vez y leve', 'Periódicamente', 'Con frecuencia y de intensidad moderada', 'Constante y notable', 'Constante e intenso'], ['No', 'Rarely and mildly', 'Periodically', 'Often and moderately', 'Constant and noticeable', 'Constant and severe'])),
  qv('11111111-0000-4000-8000-000000000160', 'K7', 'physical_marker', 'higher_is_more_marker_severity',
    '¿Cómo suele cambiar su energía durante el día?', 'How does your energy usually change during the day?',
    scale(['Se mantiene estable todo el día', 'Disminuye ligeramente hacia la tarde', 'Disminuye notablemente hacia la mitad del día', 'Tengo caídas bruscas de energía', 'Tengo poca energía desde la mañana', 'Me siento agotado(a) casi todo el tiempo'], ['It remains stable throughout the day', 'It decreases slightly toward evening', 'It noticeably decreases by the middle of the day', 'I have sharp drops in energy', 'I have little energy from the morning onward', 'I feel exhausted almost constantly'])),
  qv('11111111-0000-4000-8000-000000000161', 'K8', 'psychological_marker', 'higher_is_more_marker_severity',
    '¿Durante cuánto tiempo suele mantener la atención en una sola tarea sin una disminución marcada de la concentración?',
    'How long can you usually keep your attention on one task without a marked decline in concentration?',
    scale(['Más de 2 horas', 'De 1 a 2 horas', 'De 40 a 60 minutos', 'De 20 a 40 minutos', 'De 10 a 20 minutos', 'Casi no puedo concentrarme'], ['More than 2 hours', '1–2 hours', '40–60 minutes', '20–40 minutes', '10–20 minutes', 'I can hardly concentrate'])),
  qv('11111111-0000-4000-8000-000000000162', 'K9', 'psychological_marker', 'higher_is_more_marker_severity',
    '¿Con qué frecuencia pospone asuntos o decisiones importantes?', 'How often do you postpone important matters or decisions?',
    scale(['Decido y actúo', 'A veces hay una demora breve', 'Pospongo principalmente las tareas desagradables', 'Pospongo con regularidad', 'Pospongo casi todo lo importante', 'A veces siento que prácticamente no puedo actuar'], ['I decide and act', 'There is sometimes a short delay', 'I mainly postpone unpleasant tasks', 'I postpone things regularly', 'I postpone almost everything important', 'Sometimes I feel practically unable to act'])),
  qv('11111111-0000-4000-8000-000000000163', 'K10', 'psychological_marker', 'higher_is_more_marker_severity',
    '¿Con qué frecuencia le preocupan pensamientos o inquietudes antes de dormir?', 'How often are you troubled by anxious thoughts or worries before sleep?',
    scale(['Me duermo con tranquilidad', 'A veces pienso en asuntos pendientes', 'Con frecuencia doy vueltas a los pensamientos', 'Casi todas las noches', 'Esto me dificulta conciliar el sueño', 'La ansiedad o el miedo dificultan mucho que me duerma'], ['I fall asleep calmly', 'Sometimes I think about unfinished matters', 'I often keep turning thoughts over', 'Almost every evening', 'This makes it difficult to fall asleep', 'Anxiety or fear greatly interferes with falling asleep'])),
  qv('11111111-0000-4000-8000-000000000164', 'K11', 'psychological_marker', 'higher_is_more_marker_severity',
    '¿Con qué frecuencia le invaden pensamientos persistentes de los que es difícil distraerse?',
    'How often are you overtaken by persistent thoughts that are difficult to disengage from?',
    scale(['Prácticamente nunca', 'Rara vez; pasan rápido', 'Periódicamente', 'Con frecuencia e interfieren de manera notable', 'Regresan casi constantemente', 'Ocupan prácticamente toda mi atención'], ['Practically never', 'Rarely; they pass quickly', 'Periodically', 'Often and noticeably interfere', 'They return almost constantly', 'They occupy practically all of my attention'])),
  qv('11111111-0000-4000-8000-000000000165', 'K12', 'psychological_marker', 'higher_is_more_marker_severity',
    '¿Con qué frecuencia ha tenido últimamente crisis emocionales o momentos en los que le cuesta controlar sus reacciones?',
    'How often lately have you had emotional outbursts or moments when it is difficult to control your reactions?',
    scale(['Prácticamente nunca', 'Rara vez (aproximadamente una vez al mes)', 'A veces (una vez cada una o dos semanas)', 'Con frecuencia (varias veces por semana)', 'Casi a diario', 'Siento que prácticamente no puedo controlarlo'], ['Practically never', 'Rarely (about once a month)', 'Sometimes (once every one or two weeks)', 'Often (several times a week)', 'Almost daily', 'I feel that I can hardly control it'])),
  qv('11111111-0000-4000-8000-000000000166', 'K13', 'psychological_marker', 'higher_is_more_marker_severity',
    'Si ocurre un estrés intenso, un conflicto o una sobrecarga emocional, ¿cuánto tiempo suele necesitar para recuperarse?',
    'After intense stress, conflict, or emotional overload, how long does it usually take you to recover?',
    scale(['Minutos', 'Horas', 'Alrededor de un día', 'Varios días', 'Una semana o más', 'Prácticamente no logro recuperarme por completo'], ['Minutes', 'Hours', 'About one day', 'Several days', 'One week or more', 'I am practically unable to recover fully'])),
  qv('11111111-0000-4000-8000-000000000167', 'K14', 'goal_marker', 'higher_is_more_marker_severity',
    'En este momento, ¿qué siente que está ocurriendo en las áreas más importantes de su vida?',
    'At present, what seems to be happening in the most important areas of your life?',
    scale(['Hay movimiento y crecimiento', 'En general hay avance', 'A veces hay avance y a veces estancamiento', 'Hay más estancamiento que avance', 'Hay un estancamiento casi total', 'Hay estancamiento y sensación de desesperanza'], ['There is movement and growth', 'There is mostly forward movement', 'Sometimes movement and sometimes stagnation', 'More stagnation than movement', 'Almost complete stagnation', 'Stagnation and a sense of hopelessness'])),
  qv('11111111-0000-4000-8000-000000000168', 'K15', 'goal_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿con qué frecuencia tiene periodos en los que se involucra tanto en una actividad importante para usted que pierde la noción del tiempo y se concentra por completo en el proceso?',
    'Lately, how often have you had periods when you become so engaged in an activity important to you that you lose track of time and focus completely on the process?',
    scale(['Prácticamente a diario', 'Varias veces por semana', 'Aproximadamente una vez por semana', 'Aproximadamente una vez cada dos semanas', 'Aproximadamente una vez al mes', 'No recuerdo cuándo ocurrió por última vez'], ['Practically every day', 'Several times a week', 'About once a week', 'About once every two weeks', 'About once a month', 'I do not remember when this last happened'])),
  qv('11111111-0000-4000-8000-000000000169', 'K16', 'social_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿con qué frecuencia convive en persona con otras personas?', 'Lately, how often do you have in-person social contact with other people?',
    scale(['A diario y de manera activa', 'A diario, pero superficialmente', 'Varias veces por semana', 'Aproximadamente una vez por semana', 'Con menor frecuencia', 'Casi nunca'], ['Daily and actively', 'Daily, but superficially', 'Several times a week', 'About once a week', 'Less often', 'Hardly ever'])),
  qv('11111111-0000-4000-8000-000000000170', 'K17', 'social_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿con qué frecuencia tiene conversaciones profundas con otras personas?', 'Lately, how often do you have deep conversations with other people?',
    scale(['Tres o más veces por semana', 'Una o dos veces por semana', 'Aproximadamente una vez cada dos semanas', 'Aproximadamente una vez al mes', 'Rara vez', 'No recuerdo cuándo ocurrió por última vez'], ['Three or more times a week', 'Once or twice a week', 'About once every two weeks', 'About once a month', 'Rarely', 'I do not remember when this last happened'])),
  qv('11111111-0000-4000-8000-000000000171', 'K18', 'social_marker', 'higher_is_more_marker_severity',
    '¿Con qué frecuencia siente soledad o aislamiento?', 'How often do you feel lonely or isolated?',
    scale(['Prácticamente nunca', 'A veces', 'Periódicamente', 'Con frecuencia', 'Casi siempre', 'Constantemente, incluso cuando estoy con otras personas'], ['Practically never', 'Sometimes', 'Periodically', 'Often', 'Almost always', 'Constantly, even when among other people'])),
  qv('11111111-0000-4000-8000-000000000172', 'K19', 'financial_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿cómo está cambiando su fondo de emergencia o reserva financiera?', 'Lately, how is your emergency fund or financial reserve changing?',
    scale(['Mi reserva financiera está creciendo con claridad', 'Mi reserva financiera se mantiene aproximadamente igual', 'Mi reserva financiera está disminuyendo', 'No tengo reserva financiera o no hay datos suficientes'], ['My financial reserve is clearly growing', 'My financial reserve is approximately unchanged', 'My financial reserve is decreasing', 'I have no financial reserve or there is insufficient data'], [0, 2, 5, -1])),
  qv('11111111-0000-4000-8000-000000000173', 'K20', 'financial_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿cómo está cambiando su deuda o el volumen de sus obligaciones financieras?', 'Lately, how is your debt or volume of financial obligations changing?',
    scale(['Mi deuda está disminuyendo', 'Mi deuda se mantiene aproximadamente igual', 'Mi deuda está aumentando', 'No tengo deudas o no hay datos suficientes'], ['My debt is decreasing', 'My debt is approximately unchanged', 'My debt is increasing', 'I have no debt or there is insufficient data'], [0, 2, 5, -1])),
  qv('11111111-0000-4000-8000-000000000174', 'K21', 'spiritual_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿cuánto ha disminuido su interés por lo que antes era importante o interesante para usted?',
    'Lately, how much has your interest decreased in things that used to be important or interesting to you?',
    scale(['No ha disminuido', 'Ha disminuido un poco', 'Ha disminuido notablemente', 'Pocas cosas me interesan de verdad', 'Casi nada despierta mi interés', 'Prácticamente nada me interesa'], ['It has not decreased', 'It has decreased a little', 'It has decreased noticeably', 'Few things truly interest me', 'Almost nothing interests me', 'Practically nothing interests me'])),
  qv('11111111-0000-4000-8000-000000000175', 'K22', 'spiritual_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿con qué frecuencia siente que lo que ocurre carece de sentido?', 'Lately, how often do you feel that what is happening is meaningless?',
    scale(['Prácticamente nunca', 'Rara vez', 'A veces', 'Con frecuencia', 'Casi constantemente', 'Prácticamente todo el tiempo'], ['Practically never', 'Rarely', 'Sometimes', 'Often', 'Almost constantly', 'Practically all the time'])),
  qv('11111111-0000-4000-8000-000000000176', 'K23', 'critical_marker', 'higher_is_more_marker_severity',
    'Últimamente, ¿ha tenido pensamientos de no querer vivir o no querer despertar?',
    'Lately, have you had thoughts about not wanting to live or not wanting to wake up?',
    scale(['No', 'Esos pensamientos aparecieron brevemente, pero pasaron rápido', 'He sentido que no quiero despertar', 'Esos pensamientos regresan periódicamente', 'He pensado en una manera de hacerme daño', 'Tengo un plan concreto'], ['No', 'Such thoughts occurred briefly but passed quickly', 'I have felt that I do not want to wake up', 'Such thoughts return periodically', 'I have thought about a way to harm myself', 'I have a specific plan'])),
  qv('11111111-0000-4000-8000-000000000177', 'K24', 'critical_marker', 'higher_is_more_marker_severity',
    '¿Ha habido ocasiones en las que se haya autolesionado o se haya causado daño intencionalmente?',
    'Have there been occasions when you intentionally injured or harmed yourself?',
    scale(['No', 'Ocurrió anteriormente, pero no ahora', 'Ocurre a veces', 'Ocurre con regularidad'], ['No', 'It happened in the past, but not now', 'It happens sometimes', 'It happens regularly'], [0, 1, 2, 3])),
]);

const round = (value, digits = 4) => Number(value.toFixed(digits));
const mean = (values) => values.reduce((sum, value) => sum + value, 0) / values.length;
const clamp = (value, min, max) => Math.max(min, Math.min(max, value));

export const RESOURCE_ASSESSMENT_ORDER = Object.freeze([
  'T1', 'T2', 'T3', 'T4',
  'M1', 'M2', 'M3', 'M4',
  'G1', 'G2', 'G3', 'G12',
  'C1', 'C2', 'C3',
  'F1', 'F2', 'F3', 'F4',
  'P1', 'P2', 'P3',
  'RE1', 'RE2',
  'PR1', 'PR2', 'PR3', 'PR4', 'PR5', 'PR6',
  'SR1', 'SR2', 'SR3', 'SR4',
  'MG1', 'MG2', 'MG3', 'MG4', 'MG5', 'MG6', 'MG7',
  'PEP1',
  'V1', 'V2', 'V3', 'V4',
  'K1', 'K2', 'K3', 'K4', 'K5', 'K6', 'K7',
  'K8', 'K9', 'K10', 'K11', 'K12', 'K13',
  'K14', 'K15', 'K16', 'K17', 'K18',
  'K19', 'K20', 'K21', 'K22', 'K23', 'K24',
]);

const QUESTIONS_BY_CODE = new Map(HEALTH_RESOURCE_QUESTIONS.map((question) => [question.code, question]));

export const HEALTH_EVIDENCE_BLOCKS = Object.freeze([
  Object.freeze({ code: 'physical', resourceCodes: ['T1', 'T2', 'T3', 'T4'], markerCodes: ['K3', 'K6', 'K7'], numericContextCodes: ['K1', 'K2'], sensorCodes: ['K4', 'K5'], dynamicsCodes: ['RE1', 'RE2', 'V2', 'V3', 'V4'], nom035Domains: [] }),
  Object.freeze({ code: 'psychological', resourceCodes: ['M1', 'M2', 'M3', 'M4'], markerCodes: ['K8', 'K9', 'K10', 'K11', 'K12', 'K13'], numericContextCodes: [], sensorCodes: [], dynamicsCodes: ['V1', 'V2', 'PEP1'], nom035Domains: [2, 3, 4, 5, 8] }),
  Object.freeze({ code: 'goal', resourceCodes: ['G1', 'G2', 'G3', 'G12'], markerCodes: ['K14', 'K15'], numericContextCodes: [], sensorCodes: [], dynamicsCodes: ['MG1', 'MG2', 'MG3', 'MG4', 'MG5', 'MG6', 'MG7'], nom035Domains: [3, 9, 10] }),
  Object.freeze({ code: 'social', resourceCodes: ['C1', 'C2', 'C3'], markerCodes: ['K16', 'K17', 'K18'], numericContextCodes: [], sensorCodes: [], dynamicsCodes: ['SR1', 'SR2', 'SR3', 'SR4'], nom035Domains: [6, 7, 8] }),
  Object.freeze({ code: 'financial', resourceCodes: ['F1', 'F2', 'F3', 'F4'], markerCodes: ['K19', 'K20'], numericContextCodes: [], sensorCodes: [], dynamicsCodes: [], nom035Domains: [] }),
  Object.freeze({ code: 'spiritual', resourceCodes: ['P1', 'P2', 'P3'], markerCodes: ['K21', 'K22'], numericContextCodes: [], sensorCodes: [], dynamicsCodes: [], nom035Domains: [9, 10] }),
]);

const levelBand = (score) => {
  if (score === null || score === undefined || Number.isNaN(score)) return null;
  if (score <= 1) return 0;
  if (score < 2.5) return 1;
  if (score < 3.5) return 2;
  if (score < 4.5) return 3;
  return 4;
};

const validMean = (codes, answers) => {
  const values = codes.map((code) => answers[code]).filter((value) => typeof value === 'number' && value >= 0);
  return values.length ? round(mean(values)) : null;
};

export function buildBlockComparisons(answers, sensorBaselines = {}) {
  return Object.freeze(HEALTH_EVIDENCE_BLOCKS.map((block) => {
    const resourceDeficit = validMean(block.resourceCodes, answers);
    const markerSeverity = validMean(block.markerCodes, answers);
    const resourceBand = levelBand(resourceDeficit);
    const markerBand = levelBand(markerSeverity);
    const bandDistance = resourceBand === null || markerBand === null ? null : Math.abs(resourceBand - markerBand);
    const sensorEvidence = Object.freeze(block.sensorCodes.map((code) => Object.freeze({
      code,
      comparisonStatus: answers[code] == null
        ? 'NO_OBSERVATION'
        : sensorBaselines[code] == null
          ? 'BASELINE_REQUIRED'
          : 'READY_FOR_REGISTERED_NORMALIZATION',
    })));

    return Object.freeze({
      block: block.code,
      resourceDeficit,
      markerSeverity,
      resourceBand,
      markerBand,
      concordance: bandDistance === null ? 'INSUFFICIENT_DATA' : bandDistance === 0 ? 'CONCORDANT' : bandDistance === 1 ? 'ADJACENT' : 'MISMATCH_SIGNAL',
      bandDistance,
      evidence: Object.freeze({
        resourceCodes: block.resourceCodes,
        markerCodes: block.markerCodes,
        numericContextCodes: block.numericContextCodes,
        dynamicsCodes: block.dynamicsCodes,
        sensors: sensorEvidence,
        nom035DomainIds: block.nom035Domains,
      }),
      interpretationRule: 'same_construct_level_bands_v1',
      directScaleComparisonUsed: false,
    });
  }));
}

const answerIsValid = (question, value) => {
  if (value === null) return question.type === 'number' && question.constraints?.unknownAllowed === true;
  if (typeof value !== 'number' || !Number.isFinite(value)) return false;
  if (question.type === 'single_select') return question.options.some((option) => option.value === value);
  const { min, max, step } = question.constraints || {};
  if (typeof min === 'number' && value < min) return false;
  if (typeof max === 'number' && value > max) return false;
  if (step === 1 && !Number.isInteger(value)) return false;
  return true;
};

export function validateHealthResourceAnswers(answers) {
  const expectedCodes = new Set(RESOURCE_ASSESSMENT_ORDER);
  const providedCodes = Object.keys(answers || {});
  const missingCodes = [...expectedCodes].filter((code) => answers?.[code] === undefined);
  const unexpectedCodes = providedCodes.filter((code) => !expectedCodes.has(code));
  const invalidCodes = providedCodes.filter((code) => {
    const question = QUESTIONS_BY_CODE.get(code);
    return !question || !answerIsValid(question, answers[code]);
  });

  return Object.freeze({
    valid: missingCodes.length === 0 && unexpectedCodes.length === 0 && invalidCodes.length === 0,
    expectedCount: expectedCodes.size,
    providedCount: providedCodes.length,
    missingCodes: Object.freeze(missingCodes),
    unexpectedCodes: Object.freeze(unexpectedCodes),
    invalidCodes: Object.freeze(invalidCodes),
  });
}

export function calculateHealthResources(answers, context = {}) {
  const validation = validateHealthResourceAnswers(answers);
  if (!validation.valid) {
    const error = new Error('HEALTH_RESOURCES_ANSWERS_INVALID');
    error.validation = validation;
    throw error;
  }

  const deficits = {};
  for (const domain of HEALTH_RESOURCE_DOMAINS) {
    const values = domain.questionCodes.map((code) => Number(answers[code]));
    deficits[domain.resultCode] = round(mean(values));
  }

  const resourceScores = Object.fromEntries(
    Object.entries(deficits).map(([code, deficit]) => [code, round((5 - clamp(deficit, 0, 5)) * 20, 2)]),
  );
  const globalDeficit = round(mean(Object.values(deficits)));
  const overallResourceScore = round((5 - clamp(globalDeficit, 0, 5)) * 20, 2);

  const criticalProtocol = Object.freeze({
    supportRequired: Number(answers.K23) >= 1 || Number(answers.K24) >= 2,
    urgentSupportRequired: Number(answers.K23) >= 4 || Number(answers.K24) >= 3,
    employerDisclosureAllowed: false,
    rawCriticalAnswersInPublicResult: false,
  });

  const blockComparisons = buildBlockComparisons(answers, context.sensorBaselines || {});

  return Object.freeze({
    modelId: HEALTH_RESOURCES_MODEL.modelId,
    modelVersion: HEALTH_RESOURCES_MODEL.modelVersion,
    instrumentVersion: HEALTH_RESOURCES_MODEL.instrumentVersion,
    calculationVersion: HEALTH_RESOURCES_MODEL.calculationVersion,
    status: 'completed',
    completeness: Object.freeze({
      expectedResponses: 70,
      recordedResponses: 70,
      observedNumericValues: Object.values(answers).filter((value) => value !== null).length,
      ratio: 1,
    }),
    resourceDeficits: Object.freeze(deficits),
    resourceScores: Object.freeze(resourceScores),
    globalResourceDeficit: globalDeficit,
    overallResourceScore,
    recoverySignal: round(mean([Number(answers.RE1), Number(answers.RE2)])),
    expectationSignal: Number(answers.PEP1),
    stateDynamics: Object.freeze({ V1: answers.V1, V2: answers.V2, V3: answers.V3, V4: answers.V4 }),
    blockComparisons,
    criticalProtocol,
    readinessStatus: 'ORIENTING',
    forecastAllowed: false,
    diagnosisProvided: false,
    limitations: Object.freeze([
      'research_instrument_under_validation',
      'not_a_medical_or_psychological_diagnosis',
      'single_measurement_does_not_support_forecasting',
    ]),
  });
}

export function buildQuestionnaireSnapshot(language = 'es-MX') {
  const resolvedLanguage = HEALTH_RESOURCES_MODEL.supportedLanguages.includes(language) ? language : 'es-MX';
  return Object.freeze({
    model: HEALTH_RESOURCES_MODEL,
    language: resolvedLanguage,
    questions: RESOURCE_ASSESSMENT_ORDER.map((code) => QUESTIONS_BY_CODE.get(code)).map((question, position) => Object.freeze({
      position: position + 1,
      questionId: question.questionId,
      code: question.code,
      version: question.version,
      domain: question.domain,
      type: question.type,
      scoreDirection: question.scoreDirection,
      prompt: question.prompt[resolvedLanguage],
      unit: question.unit || null,
      constraints: question.constraints || null,
      options: question.options.map((option) => Object.freeze({ value: option.value, text: option.text[resolvedLanguage] })),
    })),
  });
}
