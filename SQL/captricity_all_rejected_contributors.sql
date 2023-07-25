WITH counts AS (
select 
akon_id,
COUNT(distinct external_assignment_id) as count_total,
COUNT(distinct CASE WHEN stats_external_assignment_status.status = 'approved' THEN external_assignment_id END) as count_approved, 
COUNT(distinct CASE WHEN stats_external_assignment_status.status = 'rejected' THEN external_assignment_id END) as count_rejected,
MAX(CASE WHEN stats_external_assignment_status.status = 'rejected' THEN created_at END) as most_recent_reject,
MAX(CASE WHEN stats_external_assignment_status.status = 'approved' THEN created_at END) as most_recent_approval
FROM stats_external_assignment_status 
group by akon_id
),
jobs AS (
SELECT
builder_workers.user_id as akon_id,
worker_id as contributor_id,
MAX(builder_worksets.job_id) as job_id,
flagged_at
FROM builder_worksets
JOIN builder_workers ON builder_workers.id = builder_worksets.worker_id
JOIN stats_external_assignment_status ON stats_external_assignment_status.job_id = builder_worksets.job_id
JOIN builder_jobs ON builder_jobs.id = builder_worksets.job_id
WHERE team_id = '561b1099-8ff0-48a6-bf28-d693cac5c94f'
-- AND flagged_at IS NULL
GROUP BY 1,2,4
)
select 
counts.akon_id, 
akon_users.name,
akon_users.email,
jobs.contributor_id,
jobs.job_id,
jobs.flagged_at,
disabled,
count_total,
count_approved, 
count_rejected,
(count_rejected/count_total::float) as percent_rejected,
counts.most_recent_reject,
counts.most_recent_approval,
'Suspended account - Contributor has over 100 submissions to Captricity Transcribe Data jobs and over 50 percent of them have been rejected by the customer. They are clearly taking advantage of the system.  Full report of offending contributors here: https://modeanalytics.com/crowdflower/reports/4cc7723bfc07' AS reason
-- CASE WHEN status = 'rejected' THEN count_rejected END/(count_rejected + count_approved) :: float as percent_rejected
from stats_external_assignment_status 
JOIN akon_users ON akon_users.id = stats_external_assignment_status.akon_id
JOIN counts ON counts.akon_id = akon_users.id
JOIN jobs ON jobs.akon_id = akon_users.id
JOIN builder_workers ON builder_workers.user_id = akon_users.id
WHERE (disabled IS TRUE OR jobs.flagged_at IS NOT NULL)
AND count_total >= {{num_submissions}}
AND builder_workers.external_type != 'imerit_india'
group by counts.akon_id, 
akon_users.name, 
akon_users.email, 
jobs.contributor_id,
jobs.job_id,
jobs.flagged_at,
disabled,
count_total,
count_approved, 
count_rejected,
counts.most_recent_reject,
counts.most_recent_approval
HAVING (count_rejected/count_total::float) > {{rejection_percent}}
ORDER BY counts.akon_id

{% form %}
  
rejection_percent:
  type: text
  default: 0.75   
  
num_submissions:
  type: text
  default: 100    

{% endform %}
