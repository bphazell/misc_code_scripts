
select count(distinct a.akon_id) as total_contributors, a.external_source
from public.stats_external_assignment_status a
JOIN builder_jobs j ON j.id = a.job_id
WHERE team_id = '561b1099-8ff0-48a6-bf28-d693cac5c94f'
group by external_source