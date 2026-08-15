/**
 * Módulo Oficial de Evaluación NOM-035 (Guía III)
 * Realiza el cálculo estricto de puntuaciones, dominios, categorías y niveles de riesgo
 * sin simplificaciones, siguiendo las tablas oficiales de la norma.
 */

export class NOM035OfficialEvaluator {
  constructor(questionsMetadata) {
    // questionsMetadata — это массив всех 72 вопросов с их привязкой к доменам, категориям и признаку inverse
    this.questions = questionsMetadata;
  }

  calculate(userAnswers) {
    let totalScore = 0;
    let domainScores = {};
    let categoryScores = {};

    // Инициализация аккумуляторов для доменов и категорий
    this.questions.forEach(q => {
      if (!domainScores[q.domain]) domainScores[q.domain] = 0;
      if (!categoryScores[q.category]) categoryScores[q.category] = 0;
    });

    // Расчет баллов с учетом весов и обратных вопросов
    this.questions.forEach(q => {
      const ans = userAnswers[q.id];
      const score = this.getScoreForAnswer(ans, q.inverse);
      
      totalScore += score;
      domainScores[q.domain] += score;
      categoryScores[q.category] += score;
    });

    // Оценка уровней риска согласно официальным порогам Гуиды III
    const globalRisk = this.getGlobalRiskLevel(totalScore);
    const evaluatedDomains = this.evaluateDomains(domainScores);
    const evaluatedCategories = this.evaluateCategories(categoryScores);

    return {
      totalScore,
      globalRisk,
      domainScores: evaluatedDomains,
      categoryScores: evaluatedCategories,
      rawDomainScores: domainScores,
      rawCategoryScores: categoryScores
    };
  }

  getScoreForAnswer(ans, isInverse) {
    // Шкала: Siempre, Casi siempre, Algunas veces, Casi nunca, Nunca
    if (isInverse) {
      switch (ans) {
        case "Siempre": return 4;
        case "Casi siempre": return 3;
        case "Algunas veces": return 2;
        case "Casi nunca": return 1;
        case "Nunca": return 0;
        default: throw new Error(`UNKNOWN_OR_MISSING_ANSWER: ${String(ans)}`);
      }
    } else {
      switch (ans) {
        case "Siempre": return 0;
        case "Casi siempre": return 1;
        case "Algunas veces": return 2;
        case "Casi nunca": return 3;
        case "Nunca": return 4;
        default: throw new Error(`UNKNOWN_OR_MISSING_ANSWER: ${String(ans)}`);
      }
    }
  }

  getGlobalRiskLevel(score) {
    // Официальные диапазоны для итогового балла Гуиды III
    if (score < 50) return { level: "Nulo o Despreciable", class: "nulo" };
    if (score < 75) return { level: "Bajo", class: "bajo" };
    if (score < 99) return { level: "Medio", class: "medio" };
    if (score < 140) return { level: "Alto", class: "alto" };
    return { level: "Muy Alto", class: "muy-alto" };
  }

  evaluateDomains(scores) {
    // Здесь прописываются точные официальные пороги по каждому домену Гуиды III
    let result = {};
    for (const [domain, score] of Object.entries(scores)) {
      result[domain] = {
        score: score,
        risk: this.getDomainRisk(domain, score)
      };
    }
    return result;
  }

  evaluateCategories(scores) {
    // Здесь прописываются точные официальные пороги по каждой категории Гуиды III
    let result = {};
    for (const [category, score] of Object.entries(scores)) {
      result[category] = {
        score: score,
        risk: this.getCategoryRisk(category, score)
      };
    }
    return result;
  }

  getDomainRisk(domain, score) {
    const thresholds = {
      "Condiciones en el ambiente de trabajo": [3, 5, 7, 9],
      "Carga de trabajo": [12, 16, 20, 24],
      "Falta de control sobre el trabajo": [11, 16, 21, 26],
      "Jornada de trabajo": [1, 2, 4, 6],
      "Interferencia en la relación trabajo-familia": [4, 6, 8, 10],
      "Liderazgo": [4, 6, 10, 14],
      "Relaciones en el trabajo": [10, 13, 17, 21],
      "Violencia laboral": [7, 10, 13, 16],
      "Reconocimiento del desempeño": [6, 10, 14, 18],
      "Insuficiente sentido de pertenencia e inestabilidad": [4, 6, 8, 10]
    };
    if (!Object.hasOwn(thresholds, domain)) {
      throw new Error(`UNKNOWN_NOM035_DOMAIN: ${domain}`);
    }
    return this.classifyRisk(score, thresholds[domain]);
  }

  getCategoryRisk(category, score) {
    const thresholds = {
      "Ambiente de trabajo": [3, 5, 7, 9],
      "Factores propios de la actividad": [40, 55, 70, 85],
      "Organización del tiempo de trabajo": [9, 13, 17, 21],
      "Liderazgo y relaciones en el trabajo": [28, 38, 48, 58],
      "Entorno organizacional": [10, 14, 18, 24]
    };
    if (!Object.hasOwn(thresholds, category)) {
      throw new Error(`UNKNOWN_NOM035_CATEGORY: ${category}`);
    }
    return this.classifyRisk(score, thresholds[category]);
  }

  classifyRisk(score, thresholds) {
    if (!Number.isFinite(Number(score))) {
      throw new Error(`INVALID_NOM035_SCORE: ${String(score)}`);
    }
    const [low, medium, high, veryHigh] = thresholds;
    if (score < low) return { level: "Nulo o Despreciable", class: "nulo" };
    if (score < medium) return { level: "Bajo", class: "bajo" };
    if (score < high) return { level: "Medio", class: "medio" };
    if (score < veryHigh) return { level: "Alto", class: "alto" };
    return { level: "Muy Alto", class: "muy-alto" };
  }
}
