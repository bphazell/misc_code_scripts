select Count(builder_judgments.id) as Crowdreason_Judment_Count
from akon_team_memberships
join builder_users on builder_users.akon_id = akon_team_memberships.user_id
join builder_jobs on builder_jobs.user_id = builder_users.id
join builder_units on builder_units.job_id = builder_jobs.id
join builder_judgments on builder_units.id = builder_judgments.unit_id
where akon_team_memberships.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
and builder_units.state in (2, 3, 4, 9)
and builder_judgments.created_at >= '2015-05-01'
