export const INDICATOR_LABELS = Object.freeze({
  pulse_bpm: 'Pulso',
  nom035_global: 'NOM-035',
  nom035_domain_work_environment: 'NOM · Ambiente de trabajo',
  nom035_domain_workload: 'NOM · Carga de trabajo',
  nom035_domain_lack_of_control: 'NOM · Falta de control',
  nom035_domain_working_time: 'NOM · Jornada de trabajo',
  nom035_domain_work_family: 'NOM · Trabajo–familia',
  nom035_domain_leadership: 'NOM · Liderazgo',
  nom035_domain_work_relations: 'NOM · Relaciones laborales',
  nom035_domain_workplace_violence: 'NOM · Violencia laboral',
  nom035_domain_recognition: 'NOM · Reconocimiento',
  nom035_domain_belonging_instability: 'NOM · Pertenencia e inestabilidad',
  health_resource_physical: 'Recursos físicos',
  health_resource_psychological: 'Recursos psicológicos',
  health_resource_goal: 'Recursos de metas',
  health_resource_social: 'Recursos sociales',
  health_resource_financial: 'Recursos financieros',
  health_resource_spiritual: 'Recursos espirituales',
  health_marker_physical: 'Marcadores físicos',
  health_marker_psychological: 'Marcadores psicológicos',
  health_marker_goal: 'Marcadores de metas',
  health_marker_social: 'Marcadores sociales',
  health_marker_financial: 'Marcadores financieros',
  health_marker_spiritual: 'Marcadores espirituales'
});

export const LEVEL_LABELS = Object.freeze({
  null_or_negligible: 'Nulo o despreciable',
  low: 'Bajo',
  medium: 'Medio',
  high: 'Alto',
  very_high: 'Muy alto',
  baseline_forming: 'Formando línea base',
  unavailable: 'Sin datos'
});

export function severityColor(value, suppressed = false) {
  if (suppressed || value === null || value === undefined || !Number.isFinite(Number(value))) {
    return '#cbd5e1';
  }
  const severity = Math.max(0, Math.min(1, Number(value)));
  const hue = (1 - severity) * 120;
  return `hsl(${hue}, 82%, 42%)`;
}

export function formatIndicatorValue(item) {
  if (!item || item.suppressed || item.status === 'SMALL_CELL_SUPPRESSED') return 'Protegido';
  if (item.display_value === null || item.display_value === undefined) return '--';
  const value = Number(item.display_value);
  const unit = item.unit || '';
  return `${Number.isFinite(value) ? value : item.display_value}${unit ? ` ${unit}` : ''}`;
}

export function formatUpdatedAt(value, locale = 'es-MX') {
  if (!value) return 'Sin medición';
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) return 'Sin medición';
  return parsed.toLocaleString(locale, { dateStyle: 'short', timeStyle: 'short' });
}

export function trendSymbol(delta) {
  if (delta === null || delta === undefined || !Number.isFinite(Number(delta))) return '•';
  if (Number(delta) > 0.0001) return '↑';
  if (Number(delta) < -0.0001) return '↓';
  return '→';
}

export function indicatorCardHtml(item, { aggregate = false } = {}) {
  const code = item?.indicator_code || '';
  const label = INDICATOR_LABELS[code] || code || 'Indicador';
  const suppressed = Boolean(item?.suppressed) || item?.status === 'SMALL_CELL_SUPPRESSED';
  const severity = item?.display_severity ?? item?.normalized_severity ?? null;
  const level = suppressed
    ? 'Protegido por tamaño mínimo'
    : (item?.status === 'baseline_forming'
      ? LEVEL_LABELS.baseline_forming
      : (LEVEL_LABELS[item?.level_code] || item?.level_label || LEVEL_LABELS.unavailable));
  const value = aggregate
    ? (suppressed ? 'Protegido' : level)
    : formatIndicatorValue(item);
  const n = aggregate && !suppressed && item?.participant_count
    ? `<span class="indicator-n">n=${Number(item.participant_count)}</span>`
    : '';
  const trend = aggregate && !suppressed ? trendSymbol(item?.display_delta) : '';

  return `
    <article class="indicator-card" data-indicator-code="${escapeHtml(code)}">
      <h4>${escapeHtml(label)}</h4>
      <div class="color-square" style="background-color:${severityColor(severity, suppressed)}">
        <span>${escapeHtml(value)}</span>
        ${trend ? `<small aria-label="Cambio">${trend}</small>` : ''}
      </div>
      <div class="indicator-meta">
        <span>${escapeHtml(level)}</span>${n}
      </div>
      <div class="indicator-time">${escapeHtml(formatUpdatedAt(item?.measured_at || item?.snapshot_at))}</div>
    </article>`;
}

export function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}
