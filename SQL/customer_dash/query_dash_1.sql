select  builder_jobs.project_number as pn,
        akon_teams.name as team_name,
        builder_users.email as user_email,
        builder_jobs.title as job_title,
        builder_jobs.id as job_id,
        builder_jobs.state as job_state,
        tq_table.tq_count,
        builder_jobs.front_load as quiz_mode,
        builder_jobs.minimum_requirements as skill_requirements, 
        MAX(builder_orders.created_at) as ordered_at
from builder_jobs
join builder_orders on builder_orders.job_id = builder_jobs.id
join builder_users on builder_users.id = builder_jobs.user_id
join akon_teams on akon_teams.id = builder_jobs.team_id
join (select job_id, count(id) as tq_count
      from builder_units
      where state = 6
      group by job_id) as tq_table
  on tq_table.job_id = builder_jobs.id
where builder_orders.created_at is not null 
and builder_jobs.auto_order is false
and builder_jobs.user_id not in (35925, 15606, 37089, 47519, 13222, 29922)
and builder_orders.created_at >= current_date - 1
-- May need to think of a better way to return only paying customers due to jobs
-- with incorrect pns
and builder_jobs.project_number IN (
    select pn
    from pn_list
  )
group by builder_jobs.title,
        builder_users.email,
        akon_teams.name,
        builder_jobs.minimum_requirements, 
        builder_jobs.front_load,
        builder_jobs.id, 
        builder_jobs.user_id, 
        builder_jobs.project_number,
        builder_jobs.state,
        tq_table.tq_count
order by  MAX(builder_orders.created_at) DESC
