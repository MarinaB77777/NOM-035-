const SUPABASE_URL = 'https://hjmmphkxbnuxnpcbawpg.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqbW1waGt4Ym51eG5wY2Jhd3BnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwNDgzNjQsImV4cCI6MjEwMTYyNDM2NH0.bCfCDKS1CT7lNCuJI-Vn4gQd-VbFpcEXVj5WfU3ZpNU';
const MAX_BODY_BYTES = 32_000;

function send(res, status, payload) {
  res.statusCode = status;
  res.setHeader('Content-Type', 'application/json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.end(JSON.stringify(payload));
}

function containsForbiddenData(value, key = '') {
  if (['answers', 'rawAnswers', 'responses', 'K23', 'K24', 'criticalAnswers'].includes(key)) return true;
  if (!value || typeof value !== 'object') return false;
  return Object.entries(value).some(([childKey, child]) => containsForbiddenData(child, childKey));
}

async function verifyUser(authorization) {
  if (!authorization?.startsWith('Bearer ')) return null;
  const response = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SUPABASE_ANON_KEY, Authorization: authorization },
  });
  return response.ok ? response.json() : null;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') return send(res, 405, { error: 'METHOD_NOT_ALLOWED' });
  const contentLength = Number(req.headers['content-length'] || 0);
  if (contentLength > MAX_BODY_BYTES) return send(res, 413, { error: 'PAYLOAD_TOO_LARGE' });

  const user = await verifyUser(req.headers.authorization);
  if (!user?.id) return send(res, 401, { error: 'AUTHENTICATION_REQUIRED' });

  let body;
  try {
    body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
  } catch {
    return send(res, 400, { error: 'INVALID_JSON' });
  }
  if (!body || containsForbiddenData(body)) return send(res, 400, { error: 'RAW_OR_CRITICAL_RESPONSES_FORBIDDEN' });
  if (!['es-MX', 'en-US'].includes(body.language)) return send(res, 400, { error: 'LANGUAGE_NOT_SUPPORTED' });
  if (!body.health?.resourceScores || !Array.isArray(body.health?.blockComparisons)) return send(res, 400, { error: 'DERIVED_HEALTH_RESULT_REQUIRED' });

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) return send(res, 503, { error: 'AI_SERVICE_NOT_CONFIGURED', action: 'Configure GEMINI_API_KEY in Vercel.' });
  const model = process.env.GEMINI_MODEL || 'gemini-3.1-flash-lite';
  const languageName = body.language === 'en-US' ? 'US English' : 'Mexican Spanish';
  const safeContext = {
    health: {
      resourceScores: body.health.resourceScores,
      blockComparisons: body.health.blockComparisons.map(({ block, concordance, resourceDeficit, markerSeverity, bandDistance }) => ({ block, concordance, resourceDeficit, markerSeverity, bandDistance })),
      recoverySignal: body.health.recoverySignal ?? null,
      expectationSignal: body.health.expectationSignal ?? null,
      readinessStatus: body.health.readinessStatus || 'ORIENTING',
    },
    nom035: body.nom035 ? {
      globalRisk: body.nom035.globalRisk ?? null,
      domainScores: body.nom035.domainScores ?? null,
      validityStatus: body.nom035.validityStatus ?? null,
    } : null,
  };

  const systemInstruction = `You are an explainability assistant for a research platform combining official NOM-035 results with a Health Model research instrument under validation. Respond in ${languageName}. Never diagnose, predict an individual health outcome, make an employment decision, or imply causality. Keep NOM-035 normative scoring separate from Health Model resource scores. Compare only semantically corresponding blocks. Treat mismatch as a signal for review, not proof that one channel is correct. Sensor data require a within-person baseline. State missing data and uncertainty explicitly. Do not ask for or infer raw answers, self-harm responses, identity, or protected characteristics. Provide: (1) concise evidence summary, (2) concordances, (3) mismatches/uncertainties, (4) questions for a qualified human reviewer, and (5) limitations.`;
  const userPrompt = `Derived, non-identifying results:\n${JSON.stringify(safeContext)}\n\nUser question: ${String(body.question || '').slice(0, 1200) || 'Explain the joint evidence map.'}`;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 45_000);
  try {
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        system_instruction: { parts: [{ text: systemInstruction }] },
        contents: [{ role: 'user', parts: [{ text: userPrompt }] }],
        generationConfig: { temperature: 0.2, maxOutputTokens: 1800 },
      }),
    });
    const result = await response.json();
    if (!response.ok) return send(res, 502, { error: 'AI_PROVIDER_ERROR', details: result?.error?.message || response.statusText });
    const text = result?.candidates?.[0]?.content?.parts?.map((part) => part.text || '').join('').trim();
    if (!text) return send(res, 502, { error: 'AI_EMPTY_RESPONSE' });
    return send(res, 200, { analysis: text, model, diagnosisProvided: false, employmentDecisionProvided: false, rawResponsesUsed: false });
  } catch (error) {
    return send(res, error.name === 'AbortError' ? 504 : 502, { error: error.name === 'AbortError' ? 'AI_TIMEOUT' : 'AI_REQUEST_FAILED' });
  } finally {
    clearTimeout(timeout);
  }
}
