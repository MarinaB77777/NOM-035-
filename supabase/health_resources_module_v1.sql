begin;

create extension if not exists pgcrypto;

create table if not exists public.health_resource_question_contracts (
  code text primary key,
  question_id uuid not null unique,
  position integer not null unique check (position between 1 and 70),
  question_version integer not null default 1 check (question_version > 0),
  response_type text not null check (response_type in ('single_select', 'number')),
  allowed_values numeric[],
  minimum_value numeric,
  maximum_value numeric,
  unknown_allowed boolean not null default false,
  score_direction text not null,
  active boolean not null default true,
  check (
    (response_type = 'single_select' and allowed_values is not null)
    or
    (response_type = 'number' and allowed_values is null)
  )
);

insert into public.health_resource_question_contracts
  (code, question_id, position, response_type, allowed_values, minimum_value, maximum_value, unknown_allowed, score_direction)
values
  ('T1','11111111-0000-4000-8000-000000000087',1,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('T2','11111111-0000-4000-8000-000000000088',2,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('T3','11111111-0000-4000-8000-000000000089',3,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('T4','11111111-0000-4000-8000-000000000090',4,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('M1','11111111-0000-4000-8000-000000000091',5,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('M2','11111111-0000-4000-8000-000000000092',6,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('M3','11111111-0000-4000-8000-000000000093',7,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('M4','11111111-0000-4000-8000-000000000094',8,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('G1','11111111-0000-4000-8000-000000000095',9,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('G2','11111111-0000-4000-8000-000000000096',10,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('G3','11111111-0000-4000-8000-000000000097',11,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('G12','11111111-0000-4000-8000-000000000107',12,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('C1','11111111-0000-4000-8000-000000000109',13,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('C2','11111111-0000-4000-8000-000000000110',14,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('C3','11111111-0000-4000-8000-000000000111',15,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('F1','11111111-0000-4000-8000-000000000112',16,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('F2','11111111-0000-4000-8000-000000000113',17,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('F3','11111111-0000-4000-8000-000000000114',18,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('F4','11111111-0000-4000-8000-000000000115',19,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('P1','11111111-0000-4000-8000-000000000116',20,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('P2','11111111-0000-4000-8000-000000000117',21,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('P3','11111111-0000-4000-8000-000000000118',22,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_deficit'),
  ('RE1','11111111-0000-4000-8000-000000000044',23,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('RE2','11111111-0000-4000-8000-000000000045',24,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR1','11111111-0000-4000-8000-000000000015',25,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR2','11111111-0000-4000-8000-000000000016',26,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR3','11111111-0000-4000-8000-000000000017',27,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR4','11111111-0000-4000-8000-000000000018',28,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR5','11111111-0000-4000-8000-000000000019',29,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('PR6','11111111-0000-4000-8000-000000000020',30,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('SR1','11111111-0000-4000-8000-000000000021',31,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('SR2','11111111-0000-4000-8000-000000000022',32,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('SR3','11111111-0000-4000-8000-000000000023',33,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('SR4','11111111-0000-4000-8000-000000000024',34,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_risk'),
  ('MG1','11111111-0000-4000-8000-000000000008',35,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_goal_alignment'),
  ('MG2','11111111-0000-4000-8000-000000000009',36,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_priority_clarity'),
  ('MG3','11111111-0000-4000-8000-000000000010',37,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_conflict'),
  ('MG4','11111111-0000-4000-8000-000000000011',38,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_control'),
  ('MG5','11111111-0000-4000-8000-000000000012',39,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_cost_tolerance'),
  ('MG6','11111111-0000-4000-8000-000000000013',40,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_goal_identity'),
  ('MG7','11111111-0000-4000-8000-000000000014',41,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_flexibility'),
  ('PEP1','11111111-0000-4000-8000-000000000046',42,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_negative_expectation'),
  ('V1','11111111-0000-4000-8000-000000000127',43,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_negative_velocity'),
  ('V2','11111111-0000-4000-8000-000000000128',44,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_resource_exhaustion'),
  ('V3','11111111-0000-4000-8000-000000000129',45,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_recovery_mismatch'),
  ('V4','11111111-0000-4000-8000-000000000130',46,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_recovery_mismatch'),
  ('K1','11111111-0000-4000-8000-000000000154',47,'number',null,0,24,false,'requires_baseline_normalization'),
  ('K2','11111111-0000-4000-8000-000000000155',48,'number',null,0,30,false,'requires_baseline_normalization'),
  ('K3','11111111-0000-4000-8000-000000000156',49,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K4','11111111-0000-4000-8000-000000000157',50,'number',null,1,500,true,'requires_baseline_normalization'),
  ('K5','11111111-0000-4000-8000-000000000158',51,'number',null,20,250,true,'requires_baseline_normalization'),
  ('K6','11111111-0000-4000-8000-000000000159',52,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K7','11111111-0000-4000-8000-000000000160',53,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K8','11111111-0000-4000-8000-000000000161',54,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K9','11111111-0000-4000-8000-000000000162',55,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K10','11111111-0000-4000-8000-000000000163',56,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K11','11111111-0000-4000-8000-000000000164',57,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K12','11111111-0000-4000-8000-000000000165',58,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K13','11111111-0000-4000-8000-000000000166',59,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K14','11111111-0000-4000-8000-000000000167',60,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K15','11111111-0000-4000-8000-000000000168',61,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K16','11111111-0000-4000-8000-000000000169',62,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K17','11111111-0000-4000-8000-000000000170',63,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K18','11111111-0000-4000-8000-000000000171',64,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K19','11111111-0000-4000-8000-000000000172',65,'single_select',array[-1,0,2,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K20','11111111-0000-4000-8000-000000000173',66,'single_select',array[-1,0,2,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K21','11111111-0000-4000-8000-000000000174',67,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K22','11111111-0000-4000-8000-000000000175',68,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K23','11111111-0000-4000-8000-000000000176',69,'single_select',array[0,1,2,3,4,5]::numeric[],null,null,false,'higher_is_more_marker_severity'),
  ('K24','11111111-0000-4000-8000-000000000177',70,'single_select',array[0,1,2,3]::numeric[],null,null,false,'higher_is_more_marker_severity')
on conflict (code) do update set
  question_id = excluded.question_id,
  position = excluded.position,
  response_type = excluded.response_type,
  allowed_values = excluded.allowed_values,
  minimum_value = excluded.minimum_value,
  maximum_value = excluded.maximum_value,
  unknown_allowed = excluded.unknown_allowed,
  score_direction = excluded.score_direction,
  active = true;

create table if not exists public.health_resource_consent_versions (
  consent_id uuid primary key default gen_random_uuid(),
  consent_code text not null default 'health_resource_standard',
  version integer not null,
  status text not null check (status in ('draft', 'active', 'retired')),
  title_es text not null,
  text_es text not null,
  title_en text not null,
  text_en text not null,
  created_by uuid,
  created_at timestamptz not null default now(),
  unique (consent_code, version)
);

insert into public.health_resource_consent_versions
  (consent_code, version, status, title_es, text_es, title_en, text_en)
select
  'health_resource_standard', 1, 'active',
  'Consentimiento para la evaluación complementaria de recursos',
  'Acepto participar voluntariamente en esta sesión de evaluación de recursos. Comprendo que es un instrumento de investigación en validación, no un diagnóstico médico ni psicológico. Mis respuestas se utilizarán para analizar recursos, marcadores y su relación con factores de riesgo psicosocial. Los resultados individuales y las respuestas sensibles no serán entregados al empleador; los análisis organizacionales se presentarán de forma agregada. Este consentimiento corresponde únicamente a la sesión actual.',
  'Consent for the complementary resource assessment',
  'I voluntarily agree to participate in this resource assessment session. I understand that this is a research instrument under validation, not a medical or psychological diagnosis. My responses will be used to analyze resources, markers, and their relationship with psychosocial risk factors. Individual results and sensitive responses will not be provided to the employer; organizational analyses will be presented in aggregate form. This consent applies only to the current session.'
where not exists (
  select 1 from public.health_resource_consent_versions
  where consent_code = 'health_resource_standard' and version = 1
);

create unique index if not exists health_resource_one_active_consent
  on public.health_resource_consent_versions (consent_code)
  where status = 'active';

create table if not exists public.health_resource_sessions (
  session_id uuid primary key default gen_random_uuid(),
  respondent_user_id uuid not null,
  status text not null default 'in_progress' check (status in ('in_progress', 'completed', 'frozen')),
  assessment_id text not null default 'resource',
  assessment_version integer not null default 1,
  calculation_version text not null default 'resource-assessment-70-v1',
  language text not null check (language in ('es-MX', 'en-US')),
  consent_id uuid not null references public.health_resource_consent_versions(consent_id),
  consent_version integer not null,
  consent_title_snapshot text not null,
  consent_text_snapshot text not null,
  consent_sha256 text not null,
  consent_accepted_at timestamptz not null,
  global_time_reference timestamptz not null,
  client_time_zone text,
  client_utc_offset_minutes integer,
  nom035_result_reference text,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  safety_support_required boolean not null default false,
  urgent_support_required boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.health_resource_responses (
  response_id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.health_resource_sessions(session_id),
  respondent_user_id uuid not null,
  question_id uuid not null,
  question_version integer not null,
  code text not null references public.health_resource_question_contracts(code),
  response_status text not null check (response_status in ('answered', 'unknown')),
  answer_value numeric,
  presented_at timestamptz not null,
  answered_at timestamptz not null,
  global_time_reference timestamptz not null,
  client_time_zone text,
  client_utc_offset_minutes integer,
  created_at timestamptz not null default now(),
  unique (session_id, code),
  check (
    (response_status = 'answered' and answer_value is not null)
    or
    (response_status = 'unknown' and answer_value is null)
  )
);

create table if not exists public.health_resource_results (
  result_id uuid primary key default gen_random_uuid(),
  session_id uuid not null unique references public.health_resource_sessions(session_id),
  respondent_user_id uuid not null,
  assessment_version integer not null,
  calculation_version text not null,
  resource_deficits jsonb not null,
  resource_scores jsonb not null,
  marker_block_scores jsonb not null,
  block_comparisons jsonb not null,
  recovery_signal numeric,
  expectation_signal numeric,
  readiness_status text not null default 'ORIENTING',
  forecast_allowed boolean not null default false,
  diagnosis_provided boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles
  add column if not exists can_manage_research boolean not null default false;

create or replace function public.is_health_research_manager()
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.profiles p where p.id = auth.uid() and p.can_manage_research
  );
$$;

revoke all on function public.is_health_research_manager() from public;
grant execute on function public.is_health_research_manager() to authenticated;

create or replace function public.health_resource_mean(p_session_id uuid, p_codes text[])
returns numeric
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select avg(r.answer_value)
  from public.health_resource_responses r
  where r.session_id = p_session_id
    and r.code = any(p_codes)
    and r.response_status = 'answered'
    and r.answer_value >= 0;
$$;

revoke all on function public.health_resource_mean(uuid, text[]) from public;

create or replace function public.health_resource_level_band(p_score numeric)
returns integer
language sql
immutable
as $$
  select case
    when p_score is null then null
    when p_score <= 1 then 0
    when p_score < 2.5 then 1
    when p_score < 3.5 then 2
    when p_score < 4.5 then 3
    else 4
  end;
$$;

revoke all on function public.health_resource_level_band(numeric) from public;

create or replace function public.start_health_resource_session(
  p_language text,
  p_client_time_zone text default null,
  p_client_utc_offset_minutes integer default null,
  p_nom035_result_reference text default null
)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_consent public.health_resource_consent_versions%rowtype;
  v_session_id uuid;
  v_title text;
  v_text text;
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  if p_language not in ('es-MX', 'en-US') then raise exception 'LANGUAGE_NOT_SUPPORTED'; end if;

  select * into v_consent
  from public.health_resource_consent_versions
  where consent_code = 'health_resource_standard' and status = 'active'
  order by version desc limit 1;
  if not found then raise exception 'ACTIVE_CONSENT_NOT_FOUND'; end if;

  v_title := case when p_language = 'en-US' then v_consent.title_en else v_consent.title_es end;
  v_text := case when p_language = 'en-US' then v_consent.text_en else v_consent.text_es end;

  insert into public.health_resource_sessions (
    respondent_user_id, language, consent_id, consent_version,
    consent_title_snapshot, consent_text_snapshot, consent_sha256,
    consent_accepted_at, global_time_reference, client_time_zone,
    client_utc_offset_minutes, nom035_result_reference
  ) values (
    v_user, p_language, v_consent.consent_id, v_consent.version,
    v_title, v_text, encode(digest(v_text, 'sha256'), 'hex'),
    clock_timestamp(), clock_timestamp(), p_client_time_zone,
    p_client_utc_offset_minutes, p_nom035_result_reference
  ) returning session_id into v_session_id;

  return v_session_id;
end;
$$;

create or replace function public.save_health_resource_response(
  p_session_id uuid,
  p_code text,
  p_response_status text,
  p_answer_value numeric,
  p_presented_at timestamptz,
  p_answered_at timestamptz,
  p_client_time_zone text default null,
  p_client_utc_offset_minutes integer default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_session public.health_resource_sessions%rowtype;
  v_contract public.health_resource_question_contracts%rowtype;
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  select * into v_session from public.health_resource_sessions where session_id = p_session_id for update;
  if not found or v_session.respondent_user_id <> v_user then raise exception 'SESSION_NOT_OWNED'; end if;
  if v_session.status <> 'in_progress' then raise exception 'SESSION_IMMUTABLE'; end if;

  select * into v_contract from public.health_resource_question_contracts where code = p_code and active;
  if not found then raise exception 'QUESTION_NOT_REGISTERED'; end if;
  if p_response_status not in ('answered', 'unknown') then raise exception 'INVALID_RESPONSE_STATUS'; end if;
  if p_response_status = 'unknown' and not v_contract.unknown_allowed then raise exception 'UNKNOWN_NOT_ALLOWED'; end if;
  if p_response_status = 'unknown' and p_answer_value is not null then raise exception 'UNKNOWN_MUST_NOT_HAVE_VALUE'; end if;
  if p_response_status = 'answered' and p_answer_value is null then raise exception 'ANSWER_VALUE_REQUIRED'; end if;
  if p_response_status = 'answered' and v_contract.response_type = 'single_select' and not (p_answer_value = any(v_contract.allowed_values)) then raise exception 'VALUE_NOT_ALLOWED'; end if;
  if p_response_status = 'answered' and v_contract.response_type = 'number' and (
    (v_contract.minimum_value is not null and p_answer_value < v_contract.minimum_value)
    or (v_contract.maximum_value is not null and p_answer_value > v_contract.maximum_value)
  ) then raise exception 'VALUE_OUT_OF_RANGE'; end if;

  insert into public.health_resource_responses (
    session_id, respondent_user_id, question_id, question_version, code,
    response_status, answer_value, presented_at, answered_at,
    global_time_reference, client_time_zone, client_utc_offset_minutes
  ) values (
    p_session_id, v_user, v_contract.question_id, v_contract.question_version, p_code,
    p_response_status, p_answer_value, p_presented_at, p_answered_at,
    v_session.global_time_reference, p_client_time_zone, p_client_utc_offset_minutes
  )
  on conflict (session_id, code) do update set
    response_status = excluded.response_status,
    answer_value = excluded.answer_value,
    presented_at = excluded.presented_at,
    answered_at = excluded.answered_at,
    client_time_zone = excluded.client_time_zone,
    client_utc_offset_minutes = excluded.client_utc_offset_minutes;

  if p_code in ('K23', 'K24') then
    update public.health_resource_sessions s set
      safety_support_required = exists (
        select 1 from public.health_resource_responses r
        where r.session_id = s.session_id
          and ((r.code = 'K23' and r.answer_value >= 1) or (r.code = 'K24' and r.answer_value >= 2))
      ),
      urgent_support_required = exists (
        select 1 from public.health_resource_responses r
        where r.session_id = s.session_id
          and ((r.code = 'K23' and r.answer_value >= 4) or (r.code = 'K24' and r.answer_value >= 3))
      )
    where s.session_id = p_session_id;
  end if;
end;
$$;

create or replace function public.complete_health_resource_session(p_session_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_session public.health_resource_sessions%rowtype;
  v_count integer;
  v_deficits jsonb;
  v_scores jsonb;
  v_markers jsonb;
  v_comparisons jsonb;
  v_result_id uuid;
begin
  if v_user is null then raise exception 'AUTHENTICATION_REQUIRED'; end if;
  select * into v_session from public.health_resource_sessions where session_id = p_session_id for update;
  if not found or v_session.respondent_user_id <> v_user then raise exception 'SESSION_NOT_OWNED'; end if;
  if v_session.status <> 'in_progress' then raise exception 'SESSION_NOT_IN_PROGRESS'; end if;

  select count(*) into v_count from public.health_resource_responses where session_id = p_session_id;
  if v_count <> 70 then raise exception 'ASSESSMENT_INCOMPLETE: % of 70', v_count; end if;

  v_deficits := jsonb_build_object(
    'r_phys', public.health_resource_mean(p_session_id, array['T1','T2','T3','T4']),
    'r_psych', public.health_resource_mean(p_session_id, array['M1','M2','M3','M4']),
    'r_goal', public.health_resource_mean(p_session_id, array['G1','G2','G3','G12']),
    'r_social', public.health_resource_mean(p_session_id, array['C1','C2','C3']),
    'r_fin', public.health_resource_mean(p_session_id, array['F1','F2','F3','F4']),
    'r_spiritual', public.health_resource_mean(p_session_id, array['P1','P2','P3'])
  );
  v_scores := jsonb_build_object(
    'r_phys', round((5-(v_deficits->>'r_phys')::numeric)*20,2),
    'r_psych', round((5-(v_deficits->>'r_psych')::numeric)*20,2),
    'r_goal', round((5-(v_deficits->>'r_goal')::numeric)*20,2),
    'r_social', round((5-(v_deficits->>'r_social')::numeric)*20,2),
    'r_fin', round((5-(v_deficits->>'r_fin')::numeric)*20,2),
    'r_spiritual', round((5-(v_deficits->>'r_spiritual')::numeric)*20,2)
  );
  v_markers := jsonb_build_object(
    'physical', public.health_resource_mean(p_session_id, array['K3','K6','K7']),
    'psychological', public.health_resource_mean(p_session_id, array['K8','K9','K10','K11','K12','K13']),
    'goal', public.health_resource_mean(p_session_id, array['K14','K15']),
    'social', public.health_resource_mean(p_session_id, array['K16','K17','K18']),
    'financial', public.health_resource_mean(p_session_id, array['K19','K20']),
    'spiritual', public.health_resource_mean(p_session_id, array['K21','K22'])
  );

  select jsonb_object_agg(block_name, jsonb_build_object(
    'resource_deficit', resource_score,
    'marker_severity', marker_score,
    'resource_band', public.health_resource_level_band(resource_score),
    'marker_band', public.health_resource_level_band(marker_score),
    'band_distance', abs(public.health_resource_level_band(resource_score)-public.health_resource_level_band(marker_score)),
    'concordance', case
      when resource_score is null or marker_score is null then 'INSUFFICIENT_DATA'
      when abs(public.health_resource_level_band(resource_score)-public.health_resource_level_band(marker_score)) = 0 then 'CONCORDANT'
      when abs(public.health_resource_level_band(resource_score)-public.health_resource_level_band(marker_score)) = 1 then 'ADJACENT'
      else 'MISMATCH_SIGNAL'
    end,
    'direct_scale_comparison_used', false,
    'interpretation_rule', 'same_construct_level_bands_v1'
  )) into v_comparisons
  from (values
    ('physical', (v_deficits->>'r_phys')::numeric, (v_markers->>'physical')::numeric),
    ('psychological', (v_deficits->>'r_psych')::numeric, (v_markers->>'psychological')::numeric),
    ('goal', (v_deficits->>'r_goal')::numeric, (v_markers->>'goal')::numeric),
    ('social', (v_deficits->>'r_social')::numeric, (v_markers->>'social')::numeric),
    ('financial', (v_deficits->>'r_fin')::numeric, (v_markers->>'financial')::numeric),
    ('spiritual', (v_deficits->>'r_spiritual')::numeric, (v_markers->>'spiritual')::numeric)
  ) as blocks(block_name, resource_score, marker_score);

  insert into public.health_resource_results (
    session_id, respondent_user_id, assessment_version, calculation_version,
    resource_deficits, resource_scores, marker_block_scores, block_comparisons,
    recovery_signal, expectation_signal
  ) values (
    p_session_id, v_user, v_session.assessment_version, v_session.calculation_version,
    v_deficits, v_scores, v_markers, v_comparisons,
    public.health_resource_mean(p_session_id, array['RE1','RE2']),
    public.health_resource_mean(p_session_id, array['PEP1'])
  ) returning result_id into v_result_id;

  update public.health_resource_sessions
  set status = 'completed', completed_at = clock_timestamp()
  where session_id = p_session_id;

  return v_result_id;
end;
$$;

create or replace function public.create_health_resource_consent_version(
  p_title_es text,
  p_text_es text,
  p_title_en text,
  p_text_en text
)
returns integer
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_version integer;
begin
  if v_user is null or not public.is_health_research_manager()
  then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if length(trim(p_title_es)) < 5 or length(trim(p_title_en)) < 5
    or length(trim(p_text_es)) < 100 or length(trim(p_text_en)) < 100
  then raise exception 'CONSENT_CONTENT_INCOMPLETE'; end if;

  lock table public.health_resource_consent_versions in share row exclusive mode;
  select coalesce(max(version), 0) + 1 into v_version
  from public.health_resource_consent_versions
  where consent_code = 'health_resource_standard';
  update public.health_resource_consent_versions
  set status = 'retired'
  where consent_code = 'health_resource_standard' and status = 'active';
  insert into public.health_resource_consent_versions (
    consent_code, version, status, title_es, text_es, title_en, text_en, created_by
  ) values (
    'health_resource_standard', v_version, 'active', trim(p_title_es), trim(p_text_es), trim(p_title_en), trim(p_text_en), v_user
  );
  return v_version;
end;
$$;

create or replace function public.get_health_resource_aggregate(
  p_department_id text default null,
  p_minimum_cell_size integer default 5
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_n integer;
  v_paired_n integer;
  v_result jsonb;
begin
  if not public.is_health_research_manager() then raise exception 'RESEARCH_MANAGER_REQUIRED'; end if;
  if p_minimum_cell_size < 5 then raise exception 'MINIMUM_CELL_SIZE_MUST_BE_AT_LEAST_5'; end if;

  select count(*), count(*) filter (where s.nom035_result_reference is not null)
  into v_n, v_paired_n
  from public.health_resource_results r
  join public.health_resource_sessions s on s.session_id = r.session_id
  left join public.profiles p on p.id = r.respondent_user_id
  where s.status = 'completed'
    and (p_department_id is null or p.department_id::text = p_department_id);

  if v_n < p_minimum_cell_size then
    return jsonb_build_object(
      'status', 'SMALL_CELL_SUPPRESSED',
      'n', null,
      'minimum_cell_size', p_minimum_cell_size,
      'individual_records_included', false
    );
  end if;

  select jsonb_build_object(
    'status', 'AVAILABLE',
    'n', v_n,
    'paired_nom035_n', v_paired_n,
    'minimum_cell_size', p_minimum_cell_size,
    'individual_records_included', false,
    'resource_scores', jsonb_build_object(
      'physical', avg((r.resource_scores->>'r_phys')::numeric),
      'psychological', avg((r.resource_scores->>'r_psych')::numeric),
      'goal', avg((r.resource_scores->>'r_goal')::numeric),
      'social', avg((r.resource_scores->>'r_social')::numeric),
      'financial', avg((r.resource_scores->>'r_fin')::numeric),
      'spiritual', avg((r.resource_scores->>'r_spiritual')::numeric)
    ),
    'marker_severity', jsonb_build_object(
      'physical', avg((r.marker_block_scores->>'physical')::numeric),
      'psychological', avg((r.marker_block_scores->>'psychological')::numeric),
      'goal', avg((r.marker_block_scores->>'goal')::numeric),
      'social', avg((r.marker_block_scores->>'social')::numeric),
      'financial', avg((r.marker_block_scores->>'financial')::numeric),
      'spiritual', avg((r.marker_block_scores->>'spiritual')::numeric)
    )
  ) into v_result
  from public.health_resource_results r
  join public.health_resource_sessions s on s.session_id = r.session_id
  left join public.profiles p on p.id = r.respondent_user_id
  where s.status = 'completed'
    and (p_department_id is null or p.department_id::text = p_department_id);

  return v_result;
end;
$$;

alter table public.health_resource_question_contracts enable row level security;
alter table public.health_resource_consent_versions enable row level security;
alter table public.health_resource_sessions enable row level security;
alter table public.health_resource_responses enable row level security;
alter table public.health_resource_results enable row level security;

drop policy if exists health_contracts_authenticated_read on public.health_resource_question_contracts;
create policy health_contracts_authenticated_read on public.health_resource_question_contracts for select to authenticated using (active);
drop policy if exists health_consent_active_read on public.health_resource_consent_versions;
create policy health_consent_active_read on public.health_resource_consent_versions for select to authenticated using (status = 'active');
drop policy if exists health_consent_manager_read on public.health_resource_consent_versions;
create policy health_consent_manager_read on public.health_resource_consent_versions for select to authenticated using (
  public.is_health_research_manager()
);
drop policy if exists health_sessions_own_read on public.health_resource_sessions;
create policy health_sessions_own_read on public.health_resource_sessions for select to authenticated using (respondent_user_id = auth.uid());
drop policy if exists health_responses_own_read on public.health_resource_responses;
create policy health_responses_own_read on public.health_resource_responses for select to authenticated using (
  respondent_user_id = auth.uid()
  and exists (
    select 1 from public.health_resource_sessions s
    where s.session_id = health_resource_responses.session_id and s.status = 'in_progress'
  )
);
drop policy if exists health_results_own_read on public.health_resource_results;
create policy health_results_own_read on public.health_resource_results for select to authenticated using (respondent_user_id = auth.uid());

revoke all on public.health_resource_question_contracts, public.health_resource_consent_versions,
  public.health_resource_sessions, public.health_resource_responses, public.health_resource_results from anon, authenticated;
grant select on public.health_resource_question_contracts, public.health_resource_consent_versions,
  public.health_resource_sessions, public.health_resource_responses, public.health_resource_results to authenticated;
grant execute on function public.start_health_resource_session(text,text,integer,text) to authenticated;
grant execute on function public.save_health_resource_response(uuid,text,text,numeric,timestamptz,timestamptz,text,integer) to authenticated;
grant execute on function public.complete_health_resource_session(uuid) to authenticated;
grant execute on function public.create_health_resource_consent_version(text,text,text,text) to authenticated;
grant execute on function public.get_health_resource_aggregate(text,integer) to authenticated;

commit;
