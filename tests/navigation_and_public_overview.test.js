import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');

test('main page sends protected destinations through one authenticated return route', () => {
  const source = read('index.html');
  assert.match(source, /auth\.html\?next=evaluacion\.html/);
  assert.match(source, /auth\.html\?next=extra_survey\.html/);
  assert.match(source, /auth\.html\?next=admin\.html&amp;mode=admin/);
  assert.match(source, /href="overview\.html"/);
  assert.match(source, /href="psych_map\.html"/);
});

test('authentication accepts only explicitly allowed internal destinations', () => {
  const source = read('auth.html');
  assert.match(source, /allowedDestinations = new Set/);
  assert.match(source, /allowedDestinations\.has\(requestedNext\)/);
  assert.doesNotMatch(source, /window\.location\.(?:href|replace)\(requested\.get\(['"]next/);
  assert.match(source, /window\.location\.replace\(destination\)/);
  assert.match(source, /account_security\.html/);
});

test('password rotation uses authenticated Supabase Auth and does not persist passwords', () => {
  const source = read('account_security.html');
  assert.match(source, /supabase\.auth\.getSession/);
  assert.match(source, /supabase\.auth\.updateUser\(\{password,current_password:currentPassword\}\)/);
  assert.match(source, /supabase\.auth\.signOut/);
  assert.doesNotMatch(source, /\.from\(['"][^'"]+['"]\).*password/s);
});

test('every non-home HTML page has a consistent route back to home', () => {
  const pages = fs.readdirSync(root).filter(name => name.endsWith('.html') && name !== 'index.html');
  assert.ok(pages.length > 10);
  for (const page of pages) {
    assert.match(read(page), /site_navigation\.js/, `${page} lacks global home navigation`);
  }
});

test('public overview exposes protected releases only', () => {
  const page = read('overview.html');
  const sql = read('supabase/measurement_public_overview_v2.sql');
  assert.match(page, /get_public_department_indicator_overview/);
  assert.doesNotMatch(page, /observer_token|p_token|auth\.getSession/);
  assert.match(sql, /grant execute .* to anon, authenticated/);
  assert.match(sql, /case when l\.suppressed then null else l\.display_severity end/);
  assert.match(sql, /case when l\.suppressed then null else l\.participant_count end/);
  assert.doesNotMatch(sql, /respondent_user_id|raw_value|exact_severity/);
});
