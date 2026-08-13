import test from 'node:test';
import assert from 'node:assert/strict';
import {
  HEALTH_RESOURCE_QUESTIONS,
  HEALTH_RESOURCES_MODEL,
  RESOURCE_ASSESSMENT_ORDER,
  buildBlockComparisons,
  buildQuestionnaireSnapshot,
  calculateHealthResources,
  validateHealthResourceAnswers,
} from '../health_resources_model.js';

const buildAnswers = (value = 0) => Object.fromEntries(
  HEALTH_RESOURCE_QUESTIONS.map((question) => [question.code, question.type === 'number' ? (question.constraints?.min ?? 0) : value]),
);

test('registered resource assessment contains exactly 70 unique questions in contract order', () => {
  assert.equal(HEALTH_RESOURCES_MODEL.questionCount, 70);
  assert.equal(HEALTH_RESOURCE_QUESTIONS.length, 70);
  assert.equal(RESOURCE_ASSESSMENT_ORDER.length, 70);
  assert.equal(new Set(RESOURCE_ASSESSMENT_ORDER).size, 70);
  assert.deepEqual(new Set(HEALTH_RESOURCE_QUESTIONS.map(({ code }) => code)), new Set(RESOURCE_ASSESSMENT_ORDER));
});

test('all questions preserve UUID, version, direction, and complete es-MX/en-US text', () => {
  for (const question of HEALTH_RESOURCE_QUESTIONS) {
    assert.match(question.questionId, /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-8[0-9a-f]{3}-[0-9a-f]{12}$/i);
    assert.equal(question.version, 1);
    assert.ok(question.scoreDirection);
    assert.ok(question.prompt['es-MX']);
    assert.ok(question.prompt['en-US']);
    for (const option of question.options) {
      assert.ok(option.text['es-MX']);
      assert.ok(option.text['en-US']);
    }
  }
  assert.equal(buildQuestionnaireSnapshot('es-MX').questions.length, 70);
  assert.equal(buildQuestionnaireSnapshot('en-US').questions.length, 70);
});

test('unknown sensor values are recorded as unknown and never converted to zero', () => {
  const answers = buildAnswers();
  answers.K4 = null;
  answers.K5 = null;
  const validation = validateHealthResourceAnswers(answers);
  assert.equal(validation.valid, true);
  const result = calculateHealthResources(answers);
  assert.equal(result.completeness.recordedResponses, 70);
  assert.equal(result.completeness.observedNumericValues, 68);
  const physical = result.blockComparisons.find(({ block }) => block === 'physical');
  assert.deepEqual(physical.evidence.sensors.map(({ comparisonStatus }) => comparisonStatus), ['NO_OBSERVATION', 'NO_OBSERVATION']);
  assert.equal(JSON.stringify(result).includes('"K4":null'), false);
});

test('question-specific allowed values are enforced', () => {
  const answers = buildAnswers();
  answers.K19 = -1;
  answers.K20 = 5;
  answers.K24 = 3;
  assert.equal(validateHealthResourceAnswers(answers).valid, true);
  answers.K24 = 5;
  assert.deepEqual(validateHealthResourceAnswers(answers).invalidCodes, ['K24']);
});

test('block comparison detects disagreement between same-area conclusions', () => {
  const answers = buildAnswers(0);
  for (const code of ['K3', 'K6', 'K7']) answers[code] = 5;
  const physical = buildBlockComparisons(answers).find(({ block }) => block === 'physical');
  assert.equal(physical.resourceDeficit, 0);
  assert.equal(physical.markerSeverity, 5);
  assert.equal(physical.concordance, 'MISMATCH_SIGNAL');
  assert.equal(physical.directScaleComparisonUsed, false);
});

test('critical responses trigger a private safety protocol but are absent from the result payload', () => {
  const answers = buildAnswers();
  answers.K23 = 4;
  answers.K24 = 3;
  const result = calculateHealthResources(answers);
  assert.equal(result.criticalProtocol.supportRequired, true);
  assert.equal(result.criticalProtocol.urgentSupportRequired, true);
  assert.equal(result.criticalProtocol.employerDisclosureAllowed, false);
  assert.equal(JSON.stringify(result).includes('"K23"'), false);
  assert.equal(JSON.stringify(result).includes('"K24"'), false);
});

test('official NOM-035 scoring is not imported or modified by the Health Model calculator', () => {
  const result = calculateHealthResources(buildAnswers());
  assert.equal('nom035Score' in result, false);
  assert.equal(result.diagnosisProvided, false);
  assert.equal(result.forecastAllowed, false);
});
