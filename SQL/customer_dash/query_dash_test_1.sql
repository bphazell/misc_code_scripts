WITH jobs_in_range AS (
  select job_id, 
         MAX(created_at) as last_launch
  from builder_orders
  where created_at >= current_date - 7
  group by builder_orders.job_id
), 
tq_count AS (
    select builder_units.job_id, count(id) as tq
    from builder_units
    where state = 6
    group by builder_units.job_id
)
-- tq_count AS (
--   select builder_units.job_id, count(id) as tq, jobs_in_range.created_at
-- from builder_units
-- join jobs_in_range on jobs_in_range.job_id = builder_units.job_id
-- where state = 6
-- group by builder_units.job_id,
--         jobs_in_range.created_at
-- )

select  builder_jobs.title as job_title,
        builder_users.email as user_email,
        akon_teams.name as team_name,
        builder_jobs.minimum_requirements as skill_requirements, 
        builder_jobs.front_load as quiz_mode,
        builder_jobs.id as job_id,
        tq_count.tq as tq_count,
        jobs_in_range.last_launch as launched,
        builder_jobs.user_id, 
        builder_jobs.project_number as pn,
        builder_jobs.state as job_state
from builder_jobs
join pn_list on pn_list.pn = builder_jobs.project_number
join builder_users on builder_users.id = builder_jobs.user_id
join akon_teams on akon_teams.id = builder_jobs.team_id
join jobs_in_range on jobs_in_range.job_id = builder_jobs.id
join tq_count on tq_count.job_id = builder_jobs.id
