import test from 'node:test';
import assert from 'node:assert/strict';
import { NOM035OfficialEvaluator } from '../nom035_evaluator.js';

const evaluator = new NOM035OfficialEvaluator([]);

test('official Guía III category thresholds are exact at boundaries', () => {
  assert.equal(evaluator.getCategoryRisk('Ambiente de trabajo', 2).class, 'nulo');
  assert.equal(evaluator.getCategoryRisk('Ambiente de trabajo', 3).class, 'bajo');
  assert.equal(evaluator.getCategoryRisk('Ambiente de trabajo', 9).class, 'muy-alto');
  assert.equal(evaluator.getCategoryRisk('Factores propios de la actividad', 70).class, 'alto');
});

test('official Guía III domain thresholds are exact at boundaries', () => {
  assert.equal(evaluator.getDomainRisk('Carga de trabajo', 11).class, 'nulo');
  assert.equal(evaluator.getDomainRisk('Carga de trabajo', 12).class, 'bajo');
  assert.equal(evaluator.getDomainRisk('Violencia laboral', 16).class, 'muy-alto');
});

test('unknown values are never silently converted to zero', () => {
  assert.throws(() => evaluator.getScoreForAnswer(undefined, false), /UNKNOWN_OR_MISSING_ANSWER/);
  assert.throws(() => evaluator.getDomainRisk('Dominio inventado', 4), /UNKNOWN_NOM035_DOMAIN/);
  assert.throws(() => evaluator.getCategoryRisk('Categoría inventada', 4), /UNKNOWN_NOM035_CATEGORY/);
});
