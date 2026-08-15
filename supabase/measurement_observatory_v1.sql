begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

alter table public.profiles
  add column if not exists can_manage_research boolean not null default false;

create or replace function public.is_measurement_manager()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.can_manage_research
  );
$$;

revoke all on function public.is_measurement_manager() from public;
grant execute on function public.is_measurement_manager() to authenticated;

create table if not exists public.work_geofences (
  work_geofence_id uuid primary key default gen_random_uuid(),
  department_id text not null,
  zone_code text not null,
  zone_name text not null,
  center_latitude double precision not null check (center_latitude between -90 and 90),
  center_longitude double precision not null check (center_longitude between -180 and 180),
  radius_meters numeric not null check (radius_meters between 25 and 5000),
  maximum_accuracy_meters numeric not null default 100 check (maximum_accuracy_meters between 5 and 1000),
  active boolean not null default true,
  created_by uuid not null,
  created_at timestamptz not null default clock_timestamp(),
  updated_at timestamptz not null default clock_timestamp(),
  unique (department_id, zone_code)
);

comment on table public.work_geofences is
  'Authorized workplace zones. Respondent coordinates are never persisted in this table or in verification receipts.';

create table if not exists public.measurement_consent_versions (
  consent_id uuid primary key default gen_random_uuid(),
  consent_code text not null default 'sensor_telemetry_standard',
  version integer not null check (version > 0),
  status text not null check (status in ('draft','active','retired')),
  title_es text not null,
  text_es text not null,
  title_en text not null,
  text_en text not null,
  created_by uuid,
  created_at timestamptz not null default clock_timestamp(),
  unique (consent_code, version)
);

create unique index if not exists measurement_one_active_consent
  on public.measurement_consent_versions (consent_code) where status = 'active';

insert into public.measurement_consent_versions (
  consent_code, version, status, title_es, text_es, title_en, text_en
)
select
  'sensor_telemetry_standard', 1, 'active',
  'Consentimiento para la sesión de sensores y telemetría',
  'Acepto voluntariamente participar en esta sesión de medición en el centro de trabajo. Comprendo que el sistema puede recibir pulso de un dispositivo Bluetooth y solicitar una lectura puntual de ubicación únicamente para confirmar la geocerca laboral. Las coordenadas y rutas no se almacenan. Mis mediciones individuales no serán mostradas al empleador ni al responsable del taller; sólo se publicarán agregados protegidos por un tamaño mínimo de grupo. Los resultados son señales de investigación, no diagnósticos ni evaluaciones laborales individuales. Este consentimiento corresponde exclusivamente a la sesión actual.',
  'Consent for the sensor and telemetry session',
  'I voluntarily agree to participate in this workplace measurement session. I understand that the system may receive heart rate from a Bluetooth device and request a one-time location reading solely to confirm the workplace geofence. Coordinates and routes are not stored. My individual measurements will not be shown to the employer or workshop supervisor; only aggregates protected by a minimum group size will be published. Results are research signals, not diagnoses or individual employment evaluations. This consent applies only to the current session.'
where not exists (
  select 1 from public.measurement_consent_versions
  where consent_code = 'sensor_telemetry_standard' and version = 1
);

create table if not exists public.measurement_collection_sessions (
  measurement_session_id uuid primary key default gen_random_uuid(),
  respondent_user_id uuid not null,
  department_id_snapshot text,
  status text not null default 'in_progress' check (status in ('in_progress','completed','frozen')),
  consent_id uuid not null references public.measurement_consent_versions(consent_id),
  consent_version integer not null,
  consent_language text not null check (consent_language in ('es-MX','en-US')),
  consent_title_snapshot text not null,
  consent_text_snapshot text not null,
  consent_sha256 text not null,
  consent_accepted_at timestamptz not null,
  global_time_reference timestamptz not null,
  client_time_zone text,
  client_utc_offset_minutes integer check (client_utc_offset_minutes between -840 and 840),
  started_at timestamptz not null default clock_timestamp(),
  completed_at timestamptz
);

create table if not exists public.work_geofence_verifications (
  verification_id uuid primary key default gen_random_uuid(),
  measurement_session_id uuid not null references public.measurement_collection_sessions(measurement_session_id),
  respondent_user_id uuid not null,
  department_id_snapshot text,
  work_geofence_id uuid references public.work_geofences(work_geofence_id),
  verification_status text not null check (
    verification_status in ('inside_work_zone','outside_work_zone','accuracy_insufficient','no_active_zone')
  ),
  accuracy_meters numeric,
  verified_at timestamptz not null default clock_timestamp(),
  expires_at timestamptz not null,
  global_time_reference timestamptz not null default clock_timestamp(),
  check (expires_at > verified_at)
);

comment on table public.work_geofence_verifications is
  'Privacy-preserving receipts. No latitude, longitude, route, or continuous location history is stored.';

create table if not exists public.respondent_indicator_measurements (
  measurement_id uuid primary key default gen_random_uuid(),
  respondent_user_id uuid not null,
  department_id_snapshot text,
  indicator_family text not null check (indicator_family in ('pulse','nom035','health_resource','health_marker')),
  indicator_code text not null,
  block_code text,
  raw_value numeric,
  display_value numeric,
  normalized_severity numeric check (normalized_severity between 0 and 1),
  level_code text check (level_code in ('null_or_negligible','low','medium','high','very_high')),
  unit text,
  measurement_status text not null check (
    measurement_status in ('valid','baseline_forming','insufficient_context','invalidated')
  ),
  measured_at timestamptz not null,
  global_time_reference timestamptz not null,
  client_time_zone text,
  client_utc_offset_minutes integer check (client_utc_offset_minutes between -840 and 840),
  source_type text not null,
  source_reference text,
  source_version text not null,
  calculation_version text not null,
  baseline_value numeric,
  baseline_observation_count integer check (baseline_observation_count is null or baseline_observation_count >= 0),
  geofence_verification_id uuid references public.work_geofence_verifications(verification_id),
  device_reference_hash text,
  measurement_context jsonb not null default '{}'::jsonb,
  provenance jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default clock_timestamp(),
  check (measurement_status <> 'valid' or raw_value is not null),
  check (measurement_status <> 'baseline_forming' or normalized_severity is null)
);

create unique index if not exists respondent_indicator_source_identity
  on public.respondent_indicator_measurements (
    respondent_user_id, indicator_code, source_type, source_reference
  ) where source_reference is not null;

create index if not exists respondent_indicator_latest_idx
  on public.respondent_indicator_measurements (
    respondent_user_id, indicator_code, measured_at desc, created_at desc
  );

create index if not exists department_indicator_measurements_idx
  on public.respondent_indicator_measurements (
    department_id_snapshot, indicator_code, measured_at desc
  );

create table if not exists public.department_indicator_snapshots (
  snapshot_id uuid primary key default gen_random_uuid(),
  department_id text not null,
  indicator_code text not null,
  window_started_at timestamptz not null,
  window_ended_at timestamptz not null,
  participant_count integer not null check (participant_count >= 0),
  minimum_cell_size integer not null check (minimum_cell_size >= 5),
  suppressed boolean not null,
  exact_severity numeric check (exact_severity between 0 and 1),
  display_severity numeric check (display_severity between 0 and 1),
  display_delta numeric,
  level_code text check (level_code in ('null_or_negligible','low','medium','high','very_high')),
  calculation_version text not null,
  triggering_measurement_id uuid references public.respondent_indicator_measurements(measurement_id),
  snapshot_at timestamptz not null default clock_timestamp(),
  global_time_reference timestamptz not null default clock_timestamp(),
  check ((suppressed and display_severity is null) or (not suppressed and display_severity is not null))
);

create index if not exists department_indicator_snapshot_latest_idx
  on public.department_indicator_snapshots (department_id, indicator_code, snapshot_at desc);

create table if not exists public.department_observer_assignments (
  assignment_id uuid primary key default gen_random_uuid(),
  observer_user_id uuid not null,
  department_id text not null,
  active boolean not null default true,
  created_by uuid not null,
  created_at timestamptz not null default clock_timestamp(),
  unique (observer_user_id, department_id)
);

create table if not exists public.department_observer_links (
  observer_link_id uuid primary key default gen_random_uuid(),
  department_id text not null,
  link_name text not null,
  token_hash text not null unique,
  active boolean not null default true,
  expires_at timestamptz not null,
  created_by uuid not null,
  created_at timestamptz not null default clock_timestamp(),
  revoked_at timestamptz,
  check (expires_at > created_at)
);

create table if not exists public.department_observer_access_log (
  access_id uuid primary key default gen_random_uuid(),
  observer_link_id uuid not null references public.department_observer_links(observer_link_id),
  accessed_at timestamptz not null default clock_timestamp()
);

create table if not exists public.measurement_protocols (
  protocol_id uuid primary key default gen_random_uuid(),
  protocol_code text not null,
  protocol_version integer not null check (protocol_version > 0),
  protocol_kind text not null check (protocol_kind in ('nom035_official_sample','sensor_random_window')),
  department_id text,
  instrument_code text not null,
  active boolean not null default false,
  minimum_cell_size integer not null default 5 check (minimum_cell_size >= 5),
  protocol_definition jsonb not null,
  created_by uuid not null,
  created_at timestamptz not null default clock_timestamp()
);

create unique index if not exists measurement_protocol_identity_version
  on public.measurement_protocols (
    protocol_code, coalesce(department_id, '__GLOBAL__'), protocol_version
  );

create table if not exists public.measurement_sampling_roster (
  roster_id uuid primary key default gen_random_uuid(),
  respondent_user_id uuid not null unique,
  department_id text not null,
  nom035_sampling_stratum text check (nom035_sampling_stratum in ('women','men')),
  shift_code text,
  eligible boolean not null default true,
  updated_at timestamptz not null default clock_timestamp()
);

create table if not exists public.measurement_randomization_runs (
  randomization_run_id uuid primary key default gen_random_uuid(),
  protocol_id uuid not null references public.measurement_protocols(protocol_id),
  algorithm_version text not null,
  random_seed uuid not null,
  eligible_count integer not null check (eligible_count >= 0),
  target_count integer not null check (target_count >= 0),
  window_started_at timestamptz,
  window_ended_at timestamptz,
  created_by uuid not null,
  created_at timestamptz not null default clock_timestamp()
);

create table if not exists public.measurement_random_assignments (
  assignment_id uuid primary key default gen_random_uuid(),
  randomization_run_id uuid not null references public.measurement_randomization_runs(randomization_run_id),
  respondent_user_id uuid not null,
  department_id_snapshot text not null,
  sampling_stratum text,
  scheduled_at timestamptz,
  assignment_status text not null default 'scheduled' check (
    assignment_status in ('scheduled','invited','completed','missed','ineligible')
  ),
  created_at timestamptz not null default clock_timestamp(),
  unique (randomization_run_id, respondent_user_id)
);

create or replace function public.indicator_level_from_severity(p_severity numeric)
returns text
language sql
immutable
as $$
  select case
    when p_severity is null then null
    when p_severity < 0.20 then 'null_or_negligible'
    when p_severity < 0.40 then 'low'
    when p_severity < 0.60 then 'medium'
    when p_severity < 0.80 then 'high'
    else 'very_high'
  end;
$$;

create or replace function public.nom035_level_from_label(p_label text)
returns text
language sql
immutable
as $$
  select case
    when p_label ilike '%muy%alto%' then 'very_high'
    when p_label ilike '%alto%' then 'high'
    when p_label ilike '%medio%' then 'medium'
    when p_label ilike '%bajo%' then 'low'
    when p_label ilike '%nulo%' or p_label ilike '%despreciable%' then 'null_or_negligible'
    else null
  end;
$$;

create or replace function public.nom035_severity_from_level(p_level text)
returns numeric
language sql
immutable
as $$
  select case p_level
    when 'null_or_negligible' then 0.00
    when 'low' then 0.25
    when 'medium' then 0.50
    when 'high' then 0.75
    when 'very_high' then 1.00
    else null
  end;
$$;

create or replace function public.prevent_indicator_history_mutation()
returns trigger
language plpgsql
set search_path = public, pg_temp
as $$
begin
  raise exception 'APPEND_ONLY_HISTORY';
end;
$$;

drop trigger if exists respondent_indicator_append_only on public.respondent_indicator_measurements;
create trigger respondent_indicator_append_only
before update or delete on public.respondent_indicator_measurements
for each row execute function public.prevent_indicator_history_mutation();

drop trigger if exists department_indicator_append_only on public.department_indicator_snapshots;
create trigger department_indicator_append_only
before update or delete on public.department_indicator_snapshots
for each row execute function public.prevent_indicator_history_mutation();

create or replace function public.refresh_department_indicator_snapshot(
  p_department_id text,
  p_indicator_code text,
  p_triggering_measurement_id uuid,
  p_minimum_cell_size integer default 5,
  p_window_days integer default 30
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_now timestamptz := clock_timestamp();
  v_n integer := 0;
  v_exact numeric;
  v_display numeric;
  v_previous numeric;
  v_snapshot_id uuid;
begin
  if p_department_id is null then return null; end if;
  if p_minimum_cell_size < 5 then raise exception 'MINIMUM_CELL_SIZE_MUST_BE_AT_LEAST_5'; end if;
  if p_window_days < 1 or p_window_days > 3650 then raise exception 'INVALID_WINDOW_DAYS'; end if;

  with latest as (
    select distinct on (m.respondent_user_id)
      m.respondent_user_id, m.normalized_severity
    from public.respondent_indicator_measurements m
    where m.department_id_snapshot = p_department_id
      and m.indicator_code = p_indicator_code
      and m.measurement_status = 'valid'
      and m.normalized_severity is not null
      and m.measured_at >= v_now - make_interval(days => p_window_days)
    order by m.respondent_user_id, m.measured_at desc, m.created_at desc
  )
  select count(*), avg(l.normalized_severity)
  into v_n, v_exact
  from latest l;

  select s.display_severity into v_previous
  from public.department_indicator_snapshots s
  where s.department_id = p_department_id
    and s.indicator_code = p_indicator_code
    and not s.suppressed
  order by s.snapshot_at desc
  limit 1;

  v_display := case
    when v_n < p_minimum_cell_size or v_exact is null then null
    else round(v_exact, 4)
  end;

  insert into public.department_indicator_snapshots (
    department_id, indicator_code, window_started_at, window_ended_at,
    participant_count, minimum_cell_size, suppressed, exact_severity,
    display_severity, display_delta, level_code, calculation_version,
    triggering_measurement_id, snapshot_at, global_time_reference
  ) values (
    p_department_id, p_indicator_code, v_now - make_interval(days => p_window_days), v_now,
    v_n, p_minimum_cell_size, v_n < p_minimum_cell_size,
    v_exact, v_display,
    case when v_display is null or v_previous is null then null else v_display - v_previous end,
    public.indicator_level_from_severity(v_display),
    'latest-valid-per-participant-mean-v2-sensitive-color', p_triggering_measurement_id, v_now, v_now
  ) returning snapshot_id into v_snapshot_id;

  return v_snapshot_id;
end;
$$;

create or replace function public.after_indicator_measurement_refresh()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  if new.department_id_snapshot is not null
    and new.measurement_status = 'valid'
    and new.normalized_severity is not null
  then
    perform public.refresh_department_indicator_snapshot(
      new.department_id_snapshot, new.indicator_code, new.measurement_id, 5, 30
    );
  end if;
  return new;
end;
$$;

drop trigger if exists refresh_department_after_indicator on public.respondent_indicator_measurements;
create trigger refresh_department_after_indicator
after insert on public.respondent_indicator_measurements
for each row execute function public.after_indicator_measurement_refresh();

create or replace function public.configure_work_geofence(
  p_department_id text,
  p_zone_code text,
  p_zone_name text,
  p_latitude double precision,
  p_longitude double precision,
  p_radius_meters numeric,
  p_maximum_accuracy_meters numeric default 100
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_id uuid;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if p_department_id is null or length(trim(p_department_id)) = 0 then raise exception 'DEPARTMENT_REQUIRED'; end if;
  if p_latitude not between -90 and 90 or p_longitude not between -180 and 180 then raise exception 'INVALID_COORDINATES'; end if;
  if p_radius_meters not between 25 and 5000 then raise exception 'INVALID_RADIUS'; end if;

  insert into public.work_geofences (
    department_id, zone_code, zone_name, center_latitude, center_longitude,
    radius_meters, maximum_accuracy_meters, active, created_by
  ) values (
    trim(p_department_id), trim(p_zone_code), trim(p_zone_name), p_latitude, p_longitude,
    p_radius_meters, p_maximum_accuracy_meters, true, auth.uid()
  )
  on conflict (department_id, zone_code) do update set
    zone_name = excluded.zone_name,
    center_latitude = excluded.center_latitude,
    center_longitude = excluded.center_longitude,
    radius_meters = excluded.radius_meters,
    maximum_accuracy_meters = excluded.maximum_accuracy_meters,
    active = true,
    updated_at = clock_timestamp()
  returning work_geofence_id into v_id;
  return v_id;
end;
$$;

create or replace function public.start_measurement_collection_session(
  p_language text,
  p_client_time_zone text default null,
  p_client_utc_offset_minutes integer default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_department text;
  v_consent public.measurement_consent_versions%rowtype;
  v_title text;
  v_text text;
  v_session_id uuid;
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  if p_language not in ('es-MX','en-US') then raise exception 'LANGUAGE_NOT_SUPPORTED'; end if;
  select p.department_id::text into v_department from public.profiles p where p.id = v_user;
  if v_department is null then raise exception 'DEPARTMENT_REQUIRED'; end if;
  select * into v_consent
  from public.measurement_consent_versions c
  where c.consent_code = 'sensor_telemetry_standard' and c.status = 'active'
  order by c.version desc limit 1;
  if not found then raise exception 'ACTIVE_SENSOR_CONSENT_NOT_FOUND'; end if;
  v_title := case when p_language = 'en-US' then v_consent.title_en else v_consent.title_es end;
  v_text := case when p_language = 'en-US' then v_consent.text_en else v_consent.text_es end;
  insert into public.measurement_collection_sessions (
    respondent_user_id, department_id_snapshot, consent_id, consent_version,
    consent_language, consent_title_snapshot, consent_text_snapshot, consent_sha256,
    consent_accepted_at, global_time_reference, client_time_zone, client_utc_offset_minutes
  ) values (
    v_user, v_department, v_consent.consent_id, v_consent.version,
    p_language, v_title, v_text, encode(extensions.digest(v_text, 'sha256'), 'hex'),
    clock_timestamp(), clock_timestamp(), p_client_time_zone, p_client_utc_offset_minutes
  ) returning measurement_session_id into v_session_id;
  return v_session_id;
end;
$$;

create or replace function public.complete_measurement_collection_session(p_measurement_session_id uuid)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.measurement_collection_sessions s
  set status = 'completed', completed_at = clock_timestamp()
  where s.measurement_session_id = p_measurement_session_id
    and s.respondent_user_id = auth.uid()
    and s.status = 'in_progress';
  if not found then raise exception 'MEASUREMENT_SESSION_NOT_ACTIVE'; end if;
end;
$$;

create or replace function public.create_measurement_consent_version(
  p_title_es text, p_text_es text, p_title_en text, p_text_en text
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_version integer;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if length(trim(p_title_es)) < 5 or length(trim(p_title_en)) < 5
    or length(trim(p_text_es)) < 100 or length(trim(p_text_en)) < 100
  then raise exception 'CONSENT_CONTENT_INCOMPLETE'; end if;
  lock table public.measurement_consent_versions in share row exclusive mode;
  select coalesce(max(c.version),0)+1 into v_version
  from public.measurement_consent_versions c
  where c.consent_code = 'sensor_telemetry_standard';
  update public.measurement_consent_versions
  set status = 'retired'
  where consent_code = 'sensor_telemetry_standard' and status = 'active';
  insert into public.measurement_consent_versions (
    consent_code, version, status, title_es, text_es, title_en, text_en, created_by
  ) values (
    'sensor_telemetry_standard', v_version, 'active',
    trim(p_title_es), trim(p_text_es), trim(p_title_en), trim(p_text_en), auth.uid()
  );
  return v_version;
end;
$$;

create or replace function public.verify_work_geofence(
  p_measurement_session_id uuid,
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy_meters numeric
)
returns table(verification_id uuid, verification_status text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_department text;
  v_session public.measurement_collection_sessions%rowtype;
  v_zone public.work_geofences%rowtype;
  v_distance double precision;
  v_status text;
  v_id uuid;
  v_expires timestamptz := clock_timestamp() + interval '15 minutes';
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  if p_latitude not between -90 and 90 or p_longitude not between -180 and 180 then raise exception 'INVALID_COORDINATES'; end if;
  if p_accuracy_meters is null or p_accuracy_meters <= 0 then raise exception 'ACCURACY_REQUIRED'; end if;

  select p.department_id::text into v_department from public.profiles p where p.id = v_user;
  if v_department is null then raise exception 'DEPARTMENT_REQUIRED'; end if;
  select * into v_session
  from public.measurement_collection_sessions s
  where s.measurement_session_id = p_measurement_session_id
    and s.respondent_user_id = v_user and s.status = 'in_progress';
  if not found then raise exception 'ACTIVE_MEASUREMENT_SESSION_REQUIRED'; end if;

  select * into v_zone
  from public.work_geofences z
  where z.department_id = v_department and z.active
  order by z.updated_at desc
  limit 1;

  if not found then
    v_status := 'no_active_zone';
  elsif p_accuracy_meters > v_zone.maximum_accuracy_meters then
    v_status := 'accuracy_insufficient';
  else
    v_distance := 6371000 * acos(least(1.0, greatest(-1.0,
      sin(radians(p_latitude)) * sin(radians(v_zone.center_latitude)) +
      cos(radians(p_latitude)) * cos(radians(v_zone.center_latitude)) *
      cos(radians(p_longitude - v_zone.center_longitude))
    )));
    v_status := case when v_distance <= v_zone.radius_meters then 'inside_work_zone' else 'outside_work_zone' end;
  end if;

  insert into public.work_geofence_verifications (
    measurement_session_id, respondent_user_id, department_id_snapshot, work_geofence_id,
    verification_status, accuracy_meters, expires_at
  ) values (
    p_measurement_session_id, v_user, v_department, v_zone.work_geofence_id,
    v_status, p_accuracy_meters, v_expires
  ) returning work_geofence_verifications.verification_id into v_id;

  return query select v_id, v_status, v_expires;
end;
$$;

create or replace function public.record_pulse_measurement(
  p_measurement_session_id uuid,
  p_bpm integer,
  p_measured_at timestamptz,
  p_activity_context text,
  p_geofence_verification_id uuid,
  p_device_alias text default null,
  p_client_time_zone text default null,
  p_client_utc_offset_minutes integer default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_department text;
  v_session public.measurement_collection_sessions%rowtype;
  v_verification public.work_geofence_verifications%rowtype;
  v_baseline numeric;
  v_baseline_n integer;
  v_severity numeric;
  v_status text;
  v_level text;
  v_measurement_id uuid;
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  if p_bpm not between 20 and 250 then raise exception 'PULSE_OUT_OF_RANGE'; end if;
  if p_measured_at is null or p_measured_at > clock_timestamp() + interval '5 minutes' then raise exception 'INVALID_MEASUREMENT_TIME'; end if;
  if p_activity_context not in ('resting','seated','light_activity','physical_work') then raise exception 'ACTIVITY_CONTEXT_REQUIRED'; end if;

  select p.department_id::text into v_department from public.profiles p where p.id = v_user;
  if v_department is null then raise exception 'DEPARTMENT_REQUIRED'; end if;
  select * into v_session
  from public.measurement_collection_sessions s
  where s.measurement_session_id = p_measurement_session_id
    and s.respondent_user_id = v_user and s.status = 'in_progress';
  if not found then raise exception 'ACTIVE_MEASUREMENT_SESSION_REQUIRED'; end if;

  select * into v_verification
  from public.work_geofence_verifications v
  where v.verification_id = p_geofence_verification_id
    and v.respondent_user_id = v_user;
  if not found then raise exception 'GEOFENCE_VERIFICATION_REQUIRED'; end if;
  if v_verification.verification_status <> 'inside_work_zone' or v_verification.expires_at < clock_timestamp()
  then raise exception 'WORK_ZONE_VERIFICATION_NOT_VALID'; end if;
  if v_verification.measurement_session_id <> p_measurement_session_id
  then raise exception 'GEOFENCE_SESSION_MISMATCH'; end if;

  select count(*), percentile_cont(0.5) within group (order by m.raw_value)
  into v_baseline_n, v_baseline
  from (
    select m.raw_value
    from public.respondent_indicator_measurements m
    where m.respondent_user_id = v_user
      and m.indicator_code = 'pulse_bpm'
      and m.raw_value is not null
      and m.measurement_status in ('valid','baseline_forming')
      and m.measurement_context->>'activity_context' = p_activity_context
      and m.measured_at >= p_measured_at - interval '30 days'
      and m.measured_at < p_measured_at
    order by m.measured_at desc
    limit 30
  ) m;

  if v_baseline_n < 5 or v_baseline is null or v_baseline = 0 then
    v_status := 'baseline_forming';
    v_severity := null;
    v_level := null;
  else
    v_status := 'valid';
    v_severity := least(1::numeric, greatest(0::numeric,
      ((abs(p_bpm - v_baseline) / v_baseline) - 0.05) / 0.25
    ));
    v_level := public.indicator_level_from_severity(v_severity);
  end if;

  insert into public.respondent_indicator_measurements (
    respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
    raw_value, display_value, normalized_severity, level_code, unit,
    measurement_status, measured_at, global_time_reference, client_time_zone,
    client_utc_offset_minutes, source_type, source_version, calculation_version,
    baseline_value, baseline_observation_count, geofence_verification_id,
    device_reference_hash, measurement_context, provenance
  ) values (
    v_user, v_department, 'pulse', 'pulse_bpm',
    p_bpm, p_bpm, v_severity, v_level, 'bpm',
    v_status, p_measured_at, clock_timestamp(), p_client_time_zone,
    p_client_utc_offset_minutes, 'bluetooth_heart_rate', 'ble-heart-rate-service-v1',
    'pulse-relative-deviation-v1', v_baseline, v_baseline_n,
    p_geofence_verification_id,
    case when p_device_alias is null then null else encode(extensions.digest(p_device_alias, 'sha256'), 'hex') end,
    jsonb_build_object('activity_context', p_activity_context),
    jsonb_build_object('raw_coordinates_stored', false, 'diagnosis_provided', false)
  ) returning measurement_id into v_measurement_id;

  return v_measurement_id;
end;
$$;

create or replace function public.capture_nom035_indicator_from_result()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_row jsonb := to_jsonb(new);
  v_user uuid;
  v_department text;
  v_score numeric;
  v_risk text;
  v_severity numeric;
  v_level text;
  v_reference text;
  v_domain record;
  v_domain_code text;
  v_domain_level text;
  v_domain_score numeric;
  v_domain_risk text;
begin
  if v_row->>'user_id' is null or v_row->>'total_score' is null then return new; end if;
  v_user := (v_row->>'user_id')::uuid;
  v_score := (v_row->>'total_score')::numeric;
  v_risk := coalesce(v_row->>'global_risk', '');
  v_reference := coalesce(v_row->>'result_id', v_row->>'id', v_row->>'created_at');
  select p.department_id::text into v_department from public.profiles p where p.id = v_user;

  v_level := public.nom035_level_from_label(v_risk);
  v_severity := public.nom035_severity_from_level(v_level);

  insert into public.respondent_indicator_measurements (
    respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
    raw_value, display_value, normalized_severity, level_code, unit,
    measurement_status, measured_at, global_time_reference, source_type,
    source_reference, source_version, calculation_version, provenance
  ) values (
    v_user, v_department, 'nom035', 'nom035_global',
    v_score, v_score, v_severity, v_level, 'pts',
    case when v_level is null then 'insufficient_context' else 'valid' end,
    coalesce((v_row->>'created_at')::timestamptz, clock_timestamp()),
    clock_timestamp(), 'nom035_survey_result', v_reference,
    'NOM-035-STPS-2018-Guia-III', 'official-risk-band-v1',
    jsonb_build_object('risk_label', nullif(v_risk,''), 'raw_answers_stored_here', false)
  ) on conflict do nothing;

  for v_domain in
    select e.key as domain_name, e.value as domain_value
    from jsonb_each(coalesce(v_row->'domain_scores', '{}'::jsonb)) e
  loop
    v_domain_code := case v_domain.domain_name
      when 'Condiciones en el ambiente de trabajo' then 'nom035_domain_work_environment'
      when 'Carga de trabajo' then 'nom035_domain_workload'
      when 'Falta de control sobre el trabajo' then 'nom035_domain_lack_of_control'
      when 'Jornada de trabajo' then 'nom035_domain_working_time'
      when 'Interferencia en la relación trabajo-familia' then 'nom035_domain_work_family'
      when 'Liderazgo' then 'nom035_domain_leadership'
      when 'Relaciones en el trabajo' then 'nom035_domain_work_relations'
      when 'Violencia laboral' then 'nom035_domain_workplace_violence'
      when 'Reconocimiento del desempeño' then 'nom035_domain_recognition'
      when 'Insuficiente sentido de pertenencia e inestabilidad' then 'nom035_domain_belonging_instability'
      else null
    end;
    if v_domain_code is null then continue; end if;
    v_domain_score := nullif(v_domain.domain_value->>'score', '')::numeric;
    v_domain_risk := coalesce(v_domain.domain_value->>'risk', '');
    v_domain_level := public.nom035_level_from_label(v_domain_risk);
    if v_domain_score is null then continue; end if;

    insert into public.respondent_indicator_measurements (
      respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
      raw_value, display_value, normalized_severity, level_code, unit,
      measurement_status, measured_at, global_time_reference, source_type,
      source_reference, source_version, calculation_version, provenance
    ) values (
      v_user, v_department, 'nom035', v_domain_code,
      v_domain_score, v_domain_score, public.nom035_severity_from_level(v_domain_level),
      v_domain_level, 'pts',
      case when v_domain_level is null then 'insufficient_context' else 'valid' end,
      coalesce((v_row->>'created_at')::timestamptz, clock_timestamp()),
      clock_timestamp(), 'nom035_survey_result', v_reference || ':domain:' || v_domain_code,
      'NOM-035-STPS-2018-Guia-III', 'official-domain-risk-band-v1',
      jsonb_build_object(
        'official_domain_name', v_domain.domain_name,
        'risk_label', nullif(v_domain_risk,''),
        'raw_answers_stored_here', false
      )
    ) on conflict do nothing;
  end loop;
  return new;
end;
$$;

do $$
begin
  if to_regclass('public.survey_results') is not null then
    execute 'drop trigger if exists capture_nom035_indicator on public.survey_results';
    execute 'create trigger capture_nom035_indicator after insert on public.survey_results for each row execute function public.capture_nom035_indicator_from_result()';
  end if;
end;
$$;

create or replace function public.capture_health_resource_indicators()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_department text;
  v_block record;
  v_resource numeric;
  v_marker numeric;
begin
  select p.department_id::text into v_department from public.profiles p where p.id = new.respondent_user_id;

  for v_block in select * from (values
    ('physical','r_phys'), ('psychological','r_psych'), ('goal','r_goal'),
    ('social','r_social'), ('financial','r_fin'), ('spiritual','r_spiritual')
  ) as b(block_code, resource_key)
  loop
    v_resource := (new.resource_scores->>v_block.resource_key)::numeric;
    v_marker := (new.marker_block_scores->>v_block.block_code)::numeric;

    if v_resource is not null then
      insert into public.respondent_indicator_measurements (
        respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
        block_code, raw_value, display_value, normalized_severity, level_code, unit,
        measurement_status, measured_at, global_time_reference, source_type,
        source_reference, source_version, calculation_version, provenance
      ) values (
        new.respondent_user_id, v_department, 'health_resource', 'health_resource_' || v_block.block_code,
        v_block.block_code, v_resource, v_resource,
        least(1::numeric, greatest(0::numeric, (100 - v_resource) / 100)),
        public.indicator_level_from_severity(least(1::numeric, greatest(0::numeric, (100 - v_resource) / 100))),
        'resource_score', 'valid', new.created_at, clock_timestamp(), 'health_resource_result',
        new.result_id::text || ':resource:' || v_block.block_code,
        new.assessment_version::text, new.calculation_version,
        jsonb_build_object('direction', 'higher_is_more_resource', 'diagnosis_provided', false)
      ) on conflict do nothing;
    end if;

    if v_marker is not null then
      insert into public.respondent_indicator_measurements (
        respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
        block_code, raw_value, display_value, normalized_severity, level_code, unit,
        measurement_status, measured_at, global_time_reference, source_type,
        source_reference, source_version, calculation_version, provenance
      ) values (
        new.respondent_user_id, v_department, 'health_marker', 'health_marker_' || v_block.block_code,
        v_block.block_code, v_marker, v_marker,
        least(1::numeric, greatest(0::numeric, v_marker / 5)),
        public.indicator_level_from_severity(least(1::numeric, greatest(0::numeric, v_marker / 5))),
        'marker_0_5', 'valid', new.created_at, clock_timestamp(), 'health_resource_result',
        new.result_id::text || ':marker:' || v_block.block_code,
        new.assessment_version::text, new.calculation_version,
        jsonb_build_object('direction', 'higher_is_more_marker_severity', 'diagnosis_provided', false)
      ) on conflict do nothing;
    end if;
  end loop;
  return new;
end;
$$;

do $$
begin
  if to_regclass('public.health_resource_results') is not null then
    execute 'drop trigger if exists capture_health_resource_indicators on public.health_resource_results';
    execute 'create trigger capture_health_resource_indicators after insert on public.health_resource_results for each row execute function public.capture_health_resource_indicators()';
  end if;
end;
$$;

insert into public.respondent_indicator_measurements (
  respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
  block_code, raw_value, display_value, normalized_severity, level_code, unit,
  measurement_status, measured_at, global_time_reference, source_type,
  source_reference, source_version, calculation_version, provenance
)
select
  r.respondent_user_id, p.department_id::text, 'health_resource',
  'health_resource_' || b.block_code, b.block_code,
  (r.resource_scores->>b.resource_key)::numeric,
  (r.resource_scores->>b.resource_key)::numeric,
  least(1::numeric, greatest(0::numeric, (100 - (r.resource_scores->>b.resource_key)::numeric) / 100)),
  public.indicator_level_from_severity(
    least(1::numeric, greatest(0::numeric, (100 - (r.resource_scores->>b.resource_key)::numeric) / 100))
  ),
  'resource_score', 'valid', r.created_at, clock_timestamp(),
  'health_resource_result', r.result_id::text || ':resource:' || b.block_code,
  r.assessment_version::text, r.calculation_version,
  jsonb_build_object('direction', 'higher_is_more_resource', 'backfilled', true, 'diagnosis_provided', false)
from public.health_resource_results r
left join public.profiles p on p.id = r.respondent_user_id
cross join (values
  ('physical','r_phys'), ('psychological','r_psych'), ('goal','r_goal'),
  ('social','r_social'), ('financial','r_fin'), ('spiritual','r_spiritual')
) as b(block_code, resource_key)
where r.resource_scores->>b.resource_key is not null
on conflict do nothing;

insert into public.respondent_indicator_measurements (
  respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
  block_code, raw_value, display_value, normalized_severity, level_code, unit,
  measurement_status, measured_at, global_time_reference, source_type,
  source_reference, source_version, calculation_version, provenance
)
select
  r.respondent_user_id, p.department_id::text, 'health_marker',
  'health_marker_' || b.block_code, b.block_code,
  (r.marker_block_scores->>b.block_code)::numeric,
  (r.marker_block_scores->>b.block_code)::numeric,
  least(1::numeric, greatest(0::numeric, (r.marker_block_scores->>b.block_code)::numeric / 5)),
  public.indicator_level_from_severity(
    least(1::numeric, greatest(0::numeric, (r.marker_block_scores->>b.block_code)::numeric / 5))
  ),
  'marker_0_5', 'valid', r.created_at, clock_timestamp(),
  'health_resource_result', r.result_id::text || ':marker:' || b.block_code,
  r.assessment_version::text, r.calculation_version,
  jsonb_build_object('direction', 'higher_is_more_marker_severity', 'backfilled', true, 'diagnosis_provided', false)
from public.health_resource_results r
left join public.profiles p on p.id = r.respondent_user_id
cross join (values
  ('physical'), ('psychological'), ('goal'), ('social'), ('financial'), ('spiritual')
) as b(block_code)
where r.marker_block_scores->>b.block_code is not null
on conflict do nothing;

do $migration$
begin
  if to_regclass('public.survey_results') is not null then
    execute $sql$
      insert into public.respondent_indicator_measurements (
        respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
        raw_value, display_value, normalized_severity, level_code, unit,
        measurement_status, measured_at, global_time_reference, source_type,
        source_reference, source_version, calculation_version, provenance
      )
      select
        (q.j->>'user_id')::uuid, p.department_id::text, 'nom035', 'nom035_global',
        (q.j->>'total_score')::numeric, (q.j->>'total_score')::numeric,
        case
          when q.j->>'global_risk' ilike '%muy%alto%' then 1.00
          when q.j->>'global_risk' ilike '%alto%' then 0.75
          when q.j->>'global_risk' ilike '%medio%' then 0.50
          when q.j->>'global_risk' ilike '%bajo%' then 0.25
          when q.j->>'global_risk' ilike '%nulo%' or q.j->>'global_risk' ilike '%despreciable%' then 0.00
          else null
        end,
        case
          when q.j->>'global_risk' ilike '%muy%alto%' then 'very_high'
          when q.j->>'global_risk' ilike '%alto%' then 'high'
          when q.j->>'global_risk' ilike '%medio%' then 'medium'
          when q.j->>'global_risk' ilike '%bajo%' then 'low'
          when q.j->>'global_risk' ilike '%nulo%' or q.j->>'global_risk' ilike '%despreciable%' then 'null_or_negligible'
          else null
        end,
        'pts',
        case when q.j->>'global_risk' is null or q.j->>'global_risk' = '' then 'insufficient_context' else 'valid' end,
        coalesce(nullif(q.j->>'created_at','')::timestamptz, clock_timestamp()),
        clock_timestamp(), 'nom035_survey_result',
        coalesce(q.j->>'result_id', q.j->>'id', q.j->>'created_at'),
        'NOM-035-STPS-2018-Guia-III', 'official-risk-band-v1',
        jsonb_build_object('risk_label', q.j->>'global_risk', 'backfilled', true, 'raw_answers_stored_here', false)
      from (select to_jsonb(s) as j from public.survey_results s) q
      left join public.profiles p on p.id = (q.j->>'user_id')::uuid
      where q.j->>'user_id' is not null and q.j->>'total_score' is not null
      on conflict do nothing
    $sql$;
  end if;
end;
$migration$;

do $migration$
begin
  if to_regclass('public.survey_results') is not null then
    execute $sql$
      insert into public.respondent_indicator_measurements (
        respondent_user_id, department_id_snapshot, indicator_family, indicator_code,
        raw_value, display_value, normalized_severity, level_code, unit,
        measurement_status, measured_at, global_time_reference, source_type,
        source_reference, source_version, calculation_version, provenance
      )
      select
        (q.j->>'user_id')::uuid, p.department_id::text, 'nom035', mapped.indicator_code,
        nullif(domain_item.value->>'score','')::numeric,
        nullif(domain_item.value->>'score','')::numeric,
        public.nom035_severity_from_level(public.nom035_level_from_label(domain_item.value->>'risk')),
        public.nom035_level_from_label(domain_item.value->>'risk'),
        'pts',
        case when public.nom035_level_from_label(domain_item.value->>'risk') is null
          then 'insufficient_context' else 'valid' end,
        coalesce(nullif(q.j->>'created_at','')::timestamptz, clock_timestamp()),
        clock_timestamp(), 'nom035_survey_result',
        coalesce(q.j->>'result_id', q.j->>'id', q.j->>'created_at') || ':domain:' || mapped.indicator_code,
        'NOM-035-STPS-2018-Guia-III', 'official-domain-risk-band-v1',
        jsonb_build_object(
          'official_domain_name', domain_item.key,
          'risk_label', domain_item.value->>'risk',
          'backfilled', true,
          'raw_answers_stored_here', false
        )
      from (select to_jsonb(s) as j from public.survey_results s) q
      left join public.profiles p on p.id = (q.j->>'user_id')::uuid
      cross join lateral jsonb_each(coalesce(q.j->'domain_scores','{}'::jsonb)) domain_item
      cross join lateral (
        select case domain_item.key
          when 'Condiciones en el ambiente de trabajo' then 'nom035_domain_work_environment'
          when 'Carga de trabajo' then 'nom035_domain_workload'
          when 'Falta de control sobre el trabajo' then 'nom035_domain_lack_of_control'
          when 'Jornada de trabajo' then 'nom035_domain_working_time'
          when 'Interferencia en la relación trabajo-familia' then 'nom035_domain_work_family'
          when 'Liderazgo' then 'nom035_domain_leadership'
          when 'Relaciones en el trabajo' then 'nom035_domain_work_relations'
          when 'Violencia laboral' then 'nom035_domain_workplace_violence'
          when 'Reconocimiento del desempeño' then 'nom035_domain_recognition'
          when 'Insuficiente sentido de pertenencia e inestabilidad' then 'nom035_domain_belonging_instability'
          else null
        end as indicator_code
      ) mapped
      where q.j->>'user_id' is not null
        and mapped.indicator_code is not null
        and nullif(domain_item.value->>'score','') is not null
      on conflict do nothing
    $sql$;
  end if;
end;
$migration$;

create or replace function public.can_view_department(p_department_id text)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select public.is_measurement_manager()
    or exists (
      select 1 from public.department_observer_assignments a
      where a.observer_user_id = auth.uid() and a.department_id = p_department_id and a.active
    )
    or exists (
      select 1 from public.profiles p
      where p.id = auth.uid() and p.department_id::text = p_department_id
    );
$$;

create or replace function public.get_my_current_indicators()
returns table (
  indicator_code text, display_value numeric, normalized_severity numeric,
  level_code text, unit text, status text, baseline_value numeric,
  baseline_observation_count integer, measured_at timestamptz
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select distinct on (m.indicator_code)
    m.indicator_code, m.display_value, m.normalized_severity, m.level_code,
    m.unit, m.measurement_status, m.baseline_value,
    m.baseline_observation_count, m.measured_at
  from public.respondent_indicator_measurements m
  where m.respondent_user_id = auth.uid()
  order by m.indicator_code, m.measured_at desc, m.created_at desc;
$$;

create or replace function public.get_department_indicator_current(p_department_id text default null)
returns table (
  department_id text, indicator_code text, display_severity numeric,
  display_delta numeric, level_code text, participant_count integer,
  minimum_cell_size integer, suppressed boolean, status text, snapshot_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare v_department text;
begin
  if auth.uid() is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  v_department := p_department_id;
  if v_department is null then
    select p.department_id::text into v_department from public.profiles p where p.id = auth.uid();
  end if;
  if v_department is null then raise exception 'DEPARTMENT_REQUIRED'; end if;
  if not public.can_view_department(v_department) then raise exception 'DEPARTMENT_ACCESS_DENIED'; end if;

  return query
  select distinct on (s.indicator_code)
    s.department_id, s.indicator_code, s.display_severity,
    s.display_delta, s.level_code,
    case when s.suppressed then null else s.participant_count end,
    s.minimum_cell_size, s.suppressed,
    case when s.suppressed then 'SMALL_CELL_SUPPRESSED' else 'AVAILABLE' end,
    s.snapshot_at
  from public.department_indicator_snapshots s
  where s.department_id = v_department
  order by s.indicator_code, s.snapshot_at desc;
end;
$$;

create or replace function public.get_department_indicator_history(
  p_department_id text,
  p_days integer default 90
)
returns table (
  department_id text, indicator_code text, display_severity numeric,
  level_code text, participant_count integer, snapshot_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if p_days < 1 or p_days > 730 then raise exception 'INVALID_HISTORY_RANGE'; end if;
  if not public.can_view_department(p_department_id) then raise exception 'DEPARTMENT_ACCESS_DENIED'; end if;
  return query
  select d.department_id, d.indicator_code, d.display_severity,
    d.level_code, d.participant_count, d.snapshot_at
  from (
    select distinct on (s.indicator_code, date_trunc('day', s.snapshot_at))
      s.department_id, s.indicator_code, s.display_severity,
      s.level_code, s.participant_count, s.snapshot_at
    from public.department_indicator_snapshots s
    where s.department_id = p_department_id
      and not s.suppressed
      and s.snapshot_at >= clock_timestamp() - make_interval(days => p_days)
    order by s.indicator_code, date_trunc('day', s.snapshot_at), s.snapshot_at desc
  ) d
  order by d.snapshot_at;
end;
$$;

create or replace function public.create_department_observer_link(
  p_department_id text,
  p_link_name text,
  p_expires_at timestamptz
)
returns table(observer_link_id uuid, observer_token text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_token text := encode(extensions.gen_random_bytes(32), 'hex');
  v_id uuid;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if p_expires_at <= clock_timestamp() or p_expires_at > clock_timestamp() + interval '1 year'
  then raise exception 'INVALID_EXPIRATION'; end if;
  insert into public.department_observer_links (
    department_id, link_name, token_hash, expires_at, created_by
  ) values (
    p_department_id, trim(p_link_name), encode(extensions.digest(v_token, 'sha256'), 'hex'), p_expires_at, auth.uid()
  ) returning department_observer_links.observer_link_id into v_id;
  return query select v_id, v_token, p_expires_at;
end;
$$;

create or replace function public.get_observer_department_current(p_token text)
returns table (
  department_id text, indicator_code text, display_severity numeric,
  display_delta numeric, level_code text, participant_count integer,
  minimum_cell_size integer, suppressed boolean, status text, snapshot_at timestamptz
)
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_link public.department_observer_links%rowtype;
begin
  select * into v_link
  from public.department_observer_links l
  where l.token_hash = encode(extensions.digest(p_token, 'sha256'), 'hex')
    and l.active and l.revoked_at is null and l.expires_at > clock_timestamp();
  if not found then raise exception 'OBSERVER_LINK_INVALID_OR_EXPIRED'; end if;
  insert into public.department_observer_access_log(observer_link_id) values (v_link.observer_link_id);

  return query
  select distinct on (s.indicator_code)
    s.department_id, s.indicator_code, s.display_severity,
    s.display_delta, s.level_code,
    case when s.suppressed then null else s.participant_count end,
    s.minimum_cell_size, s.suppressed,
    case when s.suppressed then 'SMALL_CELL_SUPPRESSED' else 'AVAILABLE' end,
    s.snapshot_at
  from public.department_indicator_snapshots s
  where s.department_id = v_link.department_id
  order by s.indicator_code, s.snapshot_at desc;
end;
$$;

create or replace function public.set_my_sampling_roster(
  p_nom035_sampling_stratum text,
  p_shift_code text default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare v_department text;
begin
  if auth.uid() is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  if p_nom035_sampling_stratum not in ('women','men') then raise exception 'SAMPLING_STRATUM_REQUIRED'; end if;
  select p.department_id::text into v_department from public.profiles p where p.id = auth.uid();
  if v_department is null then raise exception 'DEPARTMENT_REQUIRED'; end if;
  insert into public.measurement_sampling_roster (
    respondent_user_id, department_id, nom035_sampling_stratum, shift_code, eligible
  ) values (auth.uid(), v_department, p_nom035_sampling_stratum, nullif(trim(p_shift_code),''), true)
  on conflict (respondent_user_id) do update set
    department_id = excluded.department_id,
    nom035_sampling_stratum = excluded.nom035_sampling_stratum,
    shift_code = excluded.shift_code,
    eligible = true,
    updated_at = clock_timestamp();
end;
$$;

create or replace function public.create_measurement_protocol(
  p_protocol_code text,
  p_protocol_kind text,
  p_department_id text,
  p_instrument_code text,
  p_minimum_cell_size integer,
  p_protocol_definition jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_id uuid;
  v_version integer;
  v_department text := nullif(trim(p_department_id),'');
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if p_protocol_kind not in ('nom035_official_sample','sensor_random_window') then raise exception 'INVALID_PROTOCOL_KIND'; end if;
  if p_minimum_cell_size < 5 then raise exception 'MINIMUM_CELL_SIZE_MUST_BE_AT_LEAST_5'; end if;
  if length(trim(p_protocol_code)) < 3 or length(trim(p_instrument_code)) < 3 then raise exception 'PROTOCOL_IDENTITY_REQUIRED'; end if;
  if p_protocol_definition is null or jsonb_typeof(p_protocol_definition) <> 'object' then raise exception 'PROTOCOL_DEFINITION_REQUIRED'; end if;

  lock table public.measurement_protocols in share row exclusive mode;
  select coalesce(max(p.protocol_version),0)+1 into v_version
  from public.measurement_protocols p
  where p.protocol_code = trim(p_protocol_code)
    and p.department_id is not distinct from v_department;
  update public.measurement_protocols
  set active = false
  where protocol_code = trim(p_protocol_code)
    and department_id is not distinct from v_department
    and active;
  insert into public.measurement_protocols (
    protocol_code, protocol_version, protocol_kind, department_id,
    instrument_code, active, minimum_cell_size, protocol_definition, created_by
  ) values (
    trim(p_protocol_code), v_version, p_protocol_kind, v_department,
    trim(p_instrument_code), true, p_minimum_cell_size, p_protocol_definition, auth.uid()
  ) returning protocol_id into v_id;
  return v_id;
end;
$$;

create or replace function public.get_measurement_protocols()
returns table (
  protocol_id uuid, protocol_code text, protocol_version integer,
  protocol_kind text, department_id text, instrument_code text,
  minimum_cell_size integer, protocol_definition jsonb
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  return query
  select p.protocol_id, p.protocol_code, p.protocol_version, p.protocol_kind,
    p.department_id, p.instrument_code, p.minimum_cell_size, p.protocol_definition
  from public.measurement_protocols p
  where p.active
  order by p.protocol_kind, p.protocol_code;
end;
$$;

create or replace function public.get_sampling_readiness(p_department_id text default null)
returns table (
  eligible_count integer, women_count integer, men_count integer,
  incomplete_stratum_count integer, official_target_count integer
)
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare v_n integer;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  select count(*)::integer into v_n
  from public.measurement_sampling_roster r
  where r.eligible and (p_department_id is null or r.department_id = p_department_id);
  return query
  select
    v_n,
    count(*) filter (where r.nom035_sampling_stratum = 'women')::integer,
    count(*) filter (where r.nom035_sampling_stratum = 'men')::integer,
    count(*) filter (where r.nom035_sampling_stratum is null)::integer,
    case when v_n <= 50 then v_n
      else ceil((0.9604 * v_n) / (0.0025 * (v_n - 1) + 0.9604))::integer end
  from public.measurement_sampling_roster r
  where r.eligible and (p_department_id is null or r.department_id = p_department_id);
end;
$$;

create or replace function public.create_nom035_random_sample(p_protocol_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_protocol public.measurement_protocols%rowtype;
  v_run uuid;
  v_seed uuid := gen_random_uuid();
  v_n integer;
  v_incomplete integer;
  v_target integer;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  select * into v_protocol from public.measurement_protocols p where p.protocol_id = p_protocol_id and p.active;
  if not found or v_protocol.protocol_kind <> 'nom035_official_sample' then raise exception 'ACTIVE_NOM035_PROTOCOL_REQUIRED'; end if;

  select count(*), count(*) filter (where r.nom035_sampling_stratum is null)
  into v_n, v_incomplete
  from public.measurement_sampling_roster r
  where r.eligible
    and (v_protocol.department_id is null or r.department_id = v_protocol.department_id);
  if v_n = 0 then raise exception 'NO_ELIGIBLE_PARTICIPANTS'; end if;
  if v_incomplete > 0 then raise exception 'SAMPLING_STRATUM_INCOMPLETE: % participants', v_incomplete; end if;

  v_target := case when v_n <= 50 then v_n
    else ceil((0.9604 * v_n) / (0.0025 * (v_n - 1) + 0.9604))::integer end;

  insert into public.measurement_randomization_runs (
    protocol_id, algorithm_version, random_seed, eligible_count, target_count, created_by
  ) values (p_protocol_id, 'nom035-proportional-stratified-sha256-v1', v_seed, v_n, v_target, auth.uid())
  returning randomization_run_id into v_run;

  insert into public.measurement_random_assignments (
    randomization_run_id, respondent_user_id, department_id_snapshot, sampling_stratum
  )
  with counts as (
    select r.nom035_sampling_stratum as stratum, count(*)::integer as stratum_n
    from public.measurement_sampling_roster r
    where r.eligible and r.nom035_sampling_stratum is not null
      and (v_protocol.department_id is null or r.department_id = v_protocol.department_id)
    group by r.nom035_sampling_stratum
  ), quotas_base as (
    select c.stratum, c.stratum_n,
      floor(v_target::numeric * c.stratum_n / v_n)::integer as base_quota,
      (v_target::numeric * c.stratum_n / v_n) - floor(v_target::numeric * c.stratum_n / v_n) as remainder
    from counts c
  ), quotas as (
    select q.stratum,
      q.base_quota + case when row_number() over (order by q.remainder desc, q.stratum)
        <= v_target - sum(q.base_quota) over () then 1 else 0 end as quota
    from quotas_base q
  ), ranked as (
    select r.*, row_number() over (
      partition by r.nom035_sampling_stratum
      order by encode(extensions.digest(v_seed::text || ':' || r.respondent_user_id::text, 'sha256'), 'hex')
    ) as stratum_rank
    from public.measurement_sampling_roster r
    where r.eligible and r.nom035_sampling_stratum is not null
      and (v_protocol.department_id is null or r.department_id = v_protocol.department_id)
  )
  select v_run, r.respondent_user_id, r.department_id, r.nom035_sampling_stratum
  from ranked r join quotas q on q.stratum = r.nom035_sampling_stratum
  where r.stratum_rank <= q.quota;

  return v_run;
end;
$$;

create or replace function public.create_sensor_randomization_run(
  p_protocol_id uuid,
  p_window_started_at timestamptz,
  p_window_ended_at timestamptz,
  p_target_count integer
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_protocol public.measurement_protocols%rowtype;
  v_run uuid;
  v_seed uuid := gen_random_uuid();
  v_n integer;
begin
  if not public.is_measurement_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  select * into v_protocol from public.measurement_protocols p where p.protocol_id = p_protocol_id and p.active;
  if not found or v_protocol.protocol_kind <> 'sensor_random_window' then raise exception 'ACTIVE_SENSOR_PROTOCOL_REQUIRED'; end if;
  if p_window_ended_at <= p_window_started_at then raise exception 'INVALID_RANDOMIZATION_WINDOW'; end if;

  select count(*) into v_n from public.measurement_sampling_roster r
  where r.eligible and (v_protocol.department_id is null or r.department_id = v_protocol.department_id);
  if p_target_count < 1 or p_target_count > v_n then raise exception 'INVALID_TARGET_COUNT'; end if;

  insert into public.measurement_randomization_runs (
    protocol_id, algorithm_version, random_seed, eligible_count, target_count,
    window_started_at, window_ended_at, created_by
  ) values (
    p_protocol_id, 'sensor-window-sha256-v1', v_seed, v_n, p_target_count,
    p_window_started_at, p_window_ended_at, auth.uid()
  ) returning randomization_run_id into v_run;

  insert into public.measurement_random_assignments (
    randomization_run_id, respondent_user_id, department_id_snapshot,
    sampling_stratum, scheduled_at
  )
  select v_run, selected.respondent_user_id, selected.department_id,
    selected.shift_code,
    p_window_started_at +
      ((p_window_ended_at - p_window_started_at) *
       ((('x' || substr(md5(v_seed::text || ':time:' || selected.respondent_user_id::text), 1, 8))::bit(32)::bigint)::numeric / 4294967295::numeric))
  from (
    select r.* from public.measurement_sampling_roster r
    where r.eligible and (v_protocol.department_id is null or r.department_id = v_protocol.department_id)
    order by encode(extensions.digest(v_seed::text || ':person:' || r.respondent_user_id::text, 'sha256'), 'hex')
    limit p_target_count
  ) selected;
  return v_run;
end;
$$;

create or replace function public.get_my_measurement_assignments()
returns table (
  assignment_id uuid, protocol_code text, protocol_kind text,
  scheduled_at timestamptz, assignment_status text
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select a.assignment_id, p.protocol_code, p.protocol_kind,
    a.scheduled_at, a.assignment_status
  from public.measurement_random_assignments a
  join public.measurement_randomization_runs r on r.randomization_run_id = a.randomization_run_id
  join public.measurement_protocols p on p.protocol_id = r.protocol_id
  where a.respondent_user_id = auth.uid()
  order by a.scheduled_at nulls last, a.created_at desc;
$$;

alter table public.work_geofences enable row level security;
alter table public.measurement_consent_versions enable row level security;
alter table public.measurement_collection_sessions enable row level security;
alter table public.work_geofence_verifications enable row level security;
alter table public.respondent_indicator_measurements enable row level security;
alter table public.department_indicator_snapshots enable row level security;
alter table public.department_observer_assignments enable row level security;
alter table public.department_observer_links enable row level security;
alter table public.department_observer_access_log enable row level security;
alter table public.measurement_protocols enable row level security;
alter table public.measurement_sampling_roster enable row level security;
alter table public.measurement_randomization_runs enable row level security;
alter table public.measurement_random_assignments enable row level security;

drop policy if exists indicator_measurements_own_read on public.respondent_indicator_measurements;
create policy indicator_measurements_own_read on public.respondent_indicator_measurements
for select to authenticated using (respondent_user_id = auth.uid());

drop policy if exists geofence_receipts_own_read on public.work_geofence_verifications;
create policy geofence_receipts_own_read on public.work_geofence_verifications
for select to authenticated using (respondent_user_id = auth.uid());

drop policy if exists measurement_consent_active_read on public.measurement_consent_versions;
create policy measurement_consent_active_read on public.measurement_consent_versions
for select to authenticated using (status = 'active');

drop policy if exists measurement_consent_manager_read on public.measurement_consent_versions;
create policy measurement_consent_manager_read on public.measurement_consent_versions
for select to authenticated using (public.is_measurement_manager());

drop policy if exists measurement_sessions_own_read on public.measurement_collection_sessions;
create policy measurement_sessions_own_read on public.measurement_collection_sessions
for select to authenticated using (respondent_user_id = auth.uid());

drop policy if exists work_geofences_manager_read on public.work_geofences;
create policy work_geofences_manager_read on public.work_geofences
for select to authenticated using (public.is_measurement_manager());

drop policy if exists protocols_manager_read on public.measurement_protocols;
create policy protocols_manager_read on public.measurement_protocols
for select to authenticated using (public.is_measurement_manager());

drop policy if exists sampling_roster_own_read on public.measurement_sampling_roster;
create policy sampling_roster_own_read on public.measurement_sampling_roster
for select to authenticated using (respondent_user_id = auth.uid());

drop policy if exists assignments_own_read on public.measurement_random_assignments;
create policy assignments_own_read on public.measurement_random_assignments
for select to authenticated using (respondent_user_id = auth.uid());

revoke all on public.work_geofences, public.measurement_consent_versions,
  public.measurement_collection_sessions, public.work_geofence_verifications,
  public.respondent_indicator_measurements, public.department_indicator_snapshots,
  public.department_observer_assignments, public.department_observer_links,
  public.department_observer_access_log, public.measurement_protocols,
  public.measurement_sampling_roster, public.measurement_randomization_runs,
  public.measurement_random_assignments from anon, authenticated;

revoke all on function public.refresh_department_indicator_snapshot(text,text,uuid,integer,integer) from public;
revoke all on function public.after_indicator_measurement_refresh() from public;
revoke all on function public.capture_nom035_indicator_from_result() from public;
revoke all on function public.capture_health_resource_indicators() from public;
revoke all on function public.configure_work_geofence(text,text,text,double precision,double precision,numeric,numeric) from public;
revoke all on function public.start_measurement_collection_session(text,text,integer) from public;
revoke all on function public.complete_measurement_collection_session(uuid) from public;
revoke all on function public.create_measurement_consent_version(text,text,text,text) from public;
revoke all on function public.verify_work_geofence(uuid,double precision,double precision,numeric) from public;
revoke all on function public.record_pulse_measurement(uuid,integer,timestamptz,text,uuid,text,text,integer) from public;
revoke all on function public.get_my_current_indicators() from public;
revoke all on function public.get_department_indicator_current(text) from public;
revoke all on function public.get_department_indicator_history(text,integer) from public;
revoke all on function public.create_department_observer_link(text,text,timestamptz) from public;
revoke all on function public.get_observer_department_current(text) from public;
revoke all on function public.set_my_sampling_roster(text,text) from public;
revoke all on function public.create_measurement_protocol(text,text,text,text,integer,jsonb) from public;
revoke all on function public.get_measurement_protocols() from public;
revoke all on function public.get_sampling_readiness(text) from public;
revoke all on function public.create_nom035_random_sample(uuid) from public;
revoke all on function public.create_sensor_randomization_run(uuid,timestamptz,timestamptz,integer) from public;
revoke all on function public.get_my_measurement_assignments() from public;

grant select on public.work_geofences, public.measurement_consent_versions,
  public.measurement_collection_sessions, public.work_geofence_verifications,
  public.respondent_indicator_measurements, public.measurement_protocols,
  public.measurement_sampling_roster, public.measurement_random_assignments to authenticated;

grant execute on function public.configure_work_geofence(text,text,text,double precision,double precision,numeric,numeric) to authenticated;
grant execute on function public.start_measurement_collection_session(text,text,integer) to authenticated;
grant execute on function public.complete_measurement_collection_session(uuid) to authenticated;
grant execute on function public.create_measurement_consent_version(text,text,text,text) to authenticated;
grant execute on function public.verify_work_geofence(uuid,double precision,double precision,numeric) to authenticated;
grant execute on function public.record_pulse_measurement(uuid,integer,timestamptz,text,uuid,text,text,integer) to authenticated;
grant execute on function public.get_my_current_indicators() to authenticated;
grant execute on function public.get_department_indicator_current(text) to authenticated;
grant execute on function public.get_department_indicator_history(text,integer) to authenticated;
grant execute on function public.create_department_observer_link(text,text,timestamptz) to authenticated;
grant execute on function public.get_observer_department_current(text) to anon, authenticated;
grant execute on function public.set_my_sampling_roster(text,text) to authenticated;
grant execute on function public.create_measurement_protocol(text,text,text,text,integer,jsonb) to authenticated;
grant execute on function public.get_measurement_protocols() to authenticated;
grant execute on function public.get_sampling_readiness(text) to authenticated;
grant execute on function public.create_nom035_random_sample(uuid) to authenticated;
grant execute on function public.create_sensor_randomization_run(uuid,timestamptz,timestamptz,integer) to authenticated;
grant execute on function public.get_my_measurement_assignments() to authenticated;

commit;
