with tq_count as (select builder_units.job_id, count(builder_units.id) as tq_count
from builder_units
where builder_units.state = 6
group by builder_units.job_id)

select builder_jobs.id,
       builder_jobs.state,
       tq_count.tq_count,
       builder_users.email,
       builder_jobs.created_at
from builder_jobs
join tq_count on builder_jobs.id = tq_count.job_id
join builder_users on builder_users.id = builder_jobs.user_id
where tq_count.tq_count < builder_jobs.after_gold
and builder_jobs.front_load = 'false'
and builder_jobs.created_at > '2014-03-15 00:00:00'
and builder_jobs.state not in (4, 5) 
and builder_users.email not like '%@crowdflower.com'
order by builder_jobs.created_at


