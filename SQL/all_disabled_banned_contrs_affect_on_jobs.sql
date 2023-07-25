with suspicious_contributors as (select a.id as akon_id, a.name, a.email, w.id as worker_id, w.external_type,a.last_sign_in_at, w.trust, a.created_at as akon_created, a.updated_at as akon_updated, w.created_at as worker_created, w.updated_at as worker_updated, a.disabled, w.banned_at
from public.builder_workers w
JOIN akon_users a ON a.id = w.user_id
WHERE (w.banned_at > '2016-06-10' OR a.disabled = true  )
AND akon_updated > '2016-06-10'
order by akon_updated DESC),

 cost as (
select (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as cost, c.job_id
from public.builder_conversions c
join public.builder_jobs j on j.id = c.job_id
JOIN suspicious_contributors sp ON sp.worker_id = c.worker_id
group by c.job_id, j.markup), 

judgments as (select count(j.id) as judgments, count(distinct(j.unit_id)) as units, j.job_id
from public.builder_judgments j
join suspicious_contributors sp ON sp.worker_id = j.worker_id
AND j.golden = 'false'
group by j.job_id),

total_rows as (
select u.job_id, COUNT(u.id) as total_ordered_rows
From public.builder_units u
WHERE u.state IN (2, 3,4,5, 9)
GROUP BY u.job_id
),
total_cost as (
select (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as total_cost_with_markup, c.job_id
from public.builder_conversions c
join public.builder_jobs j on j.id = c.job_id
group by c.job_id, j.markup
),

total as (
select count(j.id) as normal_judgments, j.unit_id, j.job_id
from public.builder_judgments j
-- where j.job_id = 888923
where j.golden = false
group by j.unit_id, j.job_id),

scammy as (
select count(j.id) as scammy_judgments, j.unit_id, j.job_id
from public.builder_judgments j
JOIN suspicious_contributors sp ON sp.worker_id = j.worker_id
-- where j.job_id = 888923
where j.golden = false
group by j.unit_id, j.job_id),

total_judgments as (
select count(j.id) as total_judgments, j.job_id
from public.builder_judgments j
where j.golden = false
group by j.job_id),

all_judgments as (
select t.normal_judgments, s.scammy_judgments, s.unit_id, s.job_id,
s.scammy_judgments::numeric / t.normal_judgments::numeric AS percentage
from total t
join scammy s on s.unit_id = t.unit_id),

scammy_percent as(
select count(case when percentage > .3 then unit_id end) as rows, job_id
from all_judgments
group by job_id)

select cost as conversions_paid_to_scammy_contributors, tc.total_cost_with_markup, 
judgments as scammy_judgments, 
tj.total_judgments, 
units as rows_with_1_scammy_judgment, p.rows as rows_with_majority_scammed_judgments, 
tr.total_ordered_rows, judgments.job_id, j.title as job_title, 
a.name as team, u.email as user
from cost
join judgments on judgments.job_id = cost.job_id
join total_judgments tj on tj.job_id = judgments.job_id
join public.builder_jobs j ON j.id = judgments.job_id
join public.akon_teams a ON a.id = j.team_id
join public.builder_users u ON j.user_id = u.id
join total_rows tr ON tr.job_id = j.id
join total_cost tc ON tc.job_id = j.id 
left join scammy_percent p on p.job_id = cost.job_id
where judgments.judgments > 1000
Order by judgments.judgments DESC