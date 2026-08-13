import test from 'node:test';
import assert from 'node:assert/strict';
import handler from '../api/ai-analysis.js';

function responseRecorder() {
  return {
    statusCode: 0,
    headers: {},
    setHeader(name, value) { this.headers[name] = value; },
    end(value) { this.body = JSON.parse(value); },
  };
}

const validHealth = {
  resourceScores: { r_phys: 50, r_psych: 50, r_goal: 50, r_social: 50, r_fin: 50, r_spiritual: 50 },
  blockComparisons: [{ block: 'physical', concordance: 'CONCORDANT', resourceDeficit: 2.5, markerSeverity: 2.5, bandDistance: 0 }],
};

test('AI endpoint requires an authenticated Supabase session', async () => {
  const res = responseRecorder();
  await handler({ method: 'POST', headers: {}, body: { language: 'es-MX', health: validHealth } }, res);
  assert.equal(res.statusCode, 401);
  assert.equal(res.body.error, 'AUTHENTICATION_REQUIRED');
});

test('AI endpoint rejects raw or critical responses before provider invocation', async () => {
  const originalFetch = global.fetch;
  global.fetch = async () => ({ ok: true, json: async () => ({ id: '00000000-0000-4000-8000-000000000001' }) });
  try {
    const res = responseRecorder();
    await handler({
      method: 'POST',
      headers: { authorization: 'Bearer test', 'content-length': '100' },
      body: { language: 'es-MX', health: validHealth, K23: 4 },
    }, res);
    assert.equal(res.statusCode, 400);
    assert.equal(res.body.error, 'RAW_OR_CRITICAL_RESPONSES_FORBIDDEN');
  } finally {
    global.fetch = originalFetch;
  }
});

test('AI endpoint reports missing server configuration instead of returning a simulated answer', async () => {
  const originalFetch = global.fetch;
  const originalKey = process.env.GEMINI_API_KEY;
  delete process.env.GEMINI_API_KEY;
  global.fetch = async () => ({ ok: true, json: async () => ({ id: '00000000-0000-4000-8000-000000000001' }) });
  try {
    const res = responseRecorder();
    await handler({
      method: 'POST',
      headers: { authorization: 'Bearer test', 'content-length': '100' },
      body: { language: 'es-MX', health: validHealth },
    }, res);
    assert.equal(res.statusCode, 503);
    assert.equal(res.body.error, 'AI_SERVICE_NOT_CONFIGURED');
  } finally {
    global.fetch = originalFetch;
    if (originalKey !== undefined) process.env.GEMINI_API_KEY = originalKey;
  }
});
