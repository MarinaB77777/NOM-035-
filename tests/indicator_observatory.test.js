import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

import {
  severityColor,
  formatIndicatorValue,
  trendSymbol,
  indicatorCardHtml
} from '../indicator_observatory.js';

test('missing and suppressed values remain neutral instead of becoming zero', () => {
  assert.equal(severityColor(null), '#cbd5e1');
  assert.equal(severityColor(undefined), '#cbd5e1');
  assert.equal(formatIndicatorValue({ display_value: null }), '--');
  assert.equal(formatIndicatorValue({ display_value: 0, unit: 'pts' }), '0 pts');
  assert.equal(formatIndicatorValue({ display_value: 80, suppressed: true }), 'Protegido');
});

test('continuous severity produces continuous green-to-red color', () => {
  assert.equal(severityColor(0), 'hsl(120, 82%, 42%)');
  assert.equal(severityColor(0.5), 'hsl(60, 82%, 42%)');
  assert.equal(severityColor(1), 'hsl(0, 82%, 42%)');
  assert.notEqual(severityColor(0.50), severityColor(0.51));
});

test('trend direction is deterministic', () => {
  assert.equal(trendSymbol(0.01), '↑');
  assert.equal(trendSymbol(-0.01), '↓');
  assert.equal(trendSymbol(0), '→');
  assert.equal(trendSymbol(null), '•');
});

test('aggregate cards never reveal suppressed participant counts', () => {
  const html = indicatorCardHtml({
    indicator_code: 'nom035_global',
    suppressed: true,
    participant_count: 4,
    display_severity: null,
    status: 'SMALL_CELL_SUPPRESSED'
  }, { aggregate: true });
  assert.match(html, /Protegido/);
  assert.doesNotMatch(html, /n=4/);
});

test('sensor page contains no fake defaults, raw-coordinate storage, or continuous GPS watch', () => {
  const source = fs.readFileSync(new URL('../sensors.html', import.meta.url), 'utf8');
  assert.doesNotMatch(source, /currentPulse\s*=\s*75/);
  assert.doesNotMatch(source, /currentNomStress\s*=\s*30/);
  assert.doesNotMatch(source, /currentHealthStress\s*=\s*20/);
  assert.doesNotMatch(source, /watchPosition/);
  assert.doesNotMatch(source, /gps_device_id/);
  assert.doesNotMatch(source, /\.from\(['"]profiles['"]\)\.update/);
  assert.match(source, /start_measurement_collection_session/);
  assert.match(source, /complete_measurement_collection_session/);
  assert.match(source, /verify_work_geofence/);
  assert.match(source, /record_pulse_measurement/);
  assert.match(source, /verifyZoneBtn[^>]*disabled/);
  assert.match(source, /connectPulseBtn[^>]*disabled/);
});

test('admin page reads only protected aggregates and has no plaintext administrator query', () => {
  const source = fs.readFileSync(new URL('../admin.html', import.meta.url), 'utf8');
  assert.doesNotMatch(source, /nom035_admins/);
  assert.doesNotMatch(source, /\.select\(['"]id, department_id, current_pulse/);
  assert.doesNotMatch(source, /getSensitiveAggregatedValue|Math\.sqrt\(sumSquares/);
  assert.match(source, /get_department_indicator_current/);
  assert.match(source, /is_measurement_manager/);
});

test('database migration is append-only and does not persist respondent coordinates', () => {
  const sql = fs.readFileSync(new URL('../supabase/measurement_observatory_v1.sql', import.meta.url), 'utf8');
  assert.match(sql, /APPEND_ONLY_HISTORY/);
  assert.match(sql, /latest-valid-per-participant-mean-v2-sensitive-color/);
  assert.match(sql, /round\(v_exact, 4\)/);
  assert.match(sql, /MINIMUM_CELL_SIZE_MUST_BE_AT_LEAST_5/);
  assert.doesNotMatch(sql, /respondent_latitude|respondent_longitude|route_history/);
  assert.match(sql, /raw_coordinates_stored', false/);
  assert.match(sql, /consent_title_snapshot/);
  assert.match(sql, /consent_text_snapshot/);
  assert.match(sql, /consent_sha256/);
  assert.match(sql, /GEOFENCE_SESSION_MISMATCH/);
  assert.match(sql, /extensions\.digest/);
  assert.doesNotMatch(sql, /(?<!extensions\.)digest\(/);
  assert.match(sql, /create_nom035_random_sample/);
  assert.match(sql, /nom035_domain_work_environment/);
  assert.match(sql, /nom035_domain_workload/);
  assert.match(sql, /official-domain-risk-band-v1/);
  assert.match(sql, /0\.9604 \* v_n/);
  assert.match(sql, /create_sensor_randomization_run/);
  assert.match(sql, /SAMPLING_STRATUM_INCOMPLETE/);
});
