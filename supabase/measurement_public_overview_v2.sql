begin;

create or replace function public.get_public_department_indicator_overview()
returns table (
  department_id text,
  department_name text,
  indicator_code text,
  display_severity numeric,
  display_delta numeric,
  level_code text,
  participant_count integer,
  minimum_cell_size integer,
  suppressed boolean,
  status text,
  snapshot_at timestamptz
)
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  with latest as (
    select distinct on (s.department_id, s.indicator_code)
      s.department_id,
      s.indicator_code,
      s.display_severity,
      s.display_delta,
      s.level_code,
      s.participant_count,
      s.minimum_cell_size,
      s.suppressed,
      s.snapshot_at
    from public.department_indicator_snapshots s
    order by s.department_id, s.indicator_code, s.snapshot_at desc
  )
  select
    l.department_id,
    coalesce(d.name, 'Departamento ' || l.department_id) as department_name,
    l.indicator_code,
    case when l.suppressed then null else l.display_severity end,
    case when l.suppressed then null else l.display_delta end,
    case when l.suppressed then null else l.level_code end,
    case when l.suppressed then null else l.participant_count end,
    l.minimum_cell_size,
    l.suppressed,
    case when l.suppressed then 'SMALL_CELL_SUPPRESSED' else 'AVAILABLE' end,
    l.snapshot_at
  from latest l
  left join public.nom035_departments d on d.id::text = l.department_id
  order by coalesce(d.name, l.department_id), l.indicator_code;
$$;

comment on function public.get_public_department_indicator_overview() is
  'Public read-only overview. Returns only protected aggregate releases; never exact severities, identities, answers, locations, or small-cell participant counts.';

revoke all on function public.get_public_department_indicator_overview() from public;
grant execute on function public.get_public_department_indicator_overview() to anon, authenticated;

commit;
