select COUNT(DISTINCT worker_ui_assignments.id) - (COUNT(DISTINCT builder_worksets.id)) as Crowdreason_Non_Quiz_Assignments
FROM akon_team_memberships
INNER JOIN builder_users ON builder_users.akon_id = akon_team_memberships.user_id
INNER JOIN builder_jobs ON builder_jobs.user_id = builder_users.id
INNER JOIN builder_worksets ON builder_worksets.job_id = builder_jobs.id
INNER JOIN worker_ui_assignments ON (worker_ui_assignments.job_id = builder_worksets.job_id
                                     AND worker_ui_assignments.builder_worker_id = builder_worksets.worker_id)
WHERE akon_team_memberships.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
AND builder_jobs.state IN (2, 3, 5)
AND builder_jobs.front_load = 'true'
AND worker_ui_assignments.finished_at >= '2015-05-01'
AND length(worker_ui_assignments.judgment_ids) > 4
AND worker_ui_assignments.finished_at IS NOT NULL
AND worker_ui_assignments.approved = true