with crowd_worksets as(
    SELECT worker_ui_assignments.builder_worker_id,
           worker_ui_assignments.job_id,
           worker_ui_assignments.finished_at
    FROM akon_team_memberships
    INNER JOIN builder_users ON builder_users.akon_id = akon_team_memberships.user_id
    INNER JOIN builder_jobs ON builder_jobs.user_id = builder_users.id
    INNER JOIN worker_ui_assignments ON worker_ui_assignments.job_id = builder_jobs.id
    WHERE akon_team_memberships.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
    AND worker_ui_assignments.state IN ('completed', 'contending')
),
min_assign_per_job as (
   SELECT min(finished_at) as finished_at,
          job_id,
          builder_worker_id
   FROM crowd_worksets
   GROUP BY job_id, builder_worker_id
),

min_assign_id as (
   SELECT worker_ui_assignments.id
   FROM worker_ui_assignments
   INNER JOIN min_assign_per_job ON (min_assign_per_job.job_id = worker_ui_assignments.job_id
                                  AND min_assign_per_job.builder_worker_id = worker_ui_assignments.builder_worker_id
                                  AND min_assign_per_job.finished_at = worker_ui_assignments.finished_at)
)

SELECT count(worker_ui_assignments.id) AS Crowdreason_Non_Quiz_Assignments
FROM akon_team_memberships
INNER JOIN builder_users ON builder_users.akon_id = akon_team_memberships.user_id
INNER JOIN builder_jobs ON builder_jobs.user_id = builder_users.id
INNER JOIN worker_ui_assignments ON worker_ui_assignments.job_id = builder_jobs.id
-- INNER JOIN builder_workers ON builder_workers.id = worker_ui_assignments.builder_worker_id
WHERE akon_team_memberships.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
AND worker_ui_assignments.id NOT IN (SELECT min_assign_id.id from min_assign_id)
AND worker_ui_assignments.finished_at >= '2015-05-01'
AND worker_ui_assignments.state IN ('completed', 'contending')
-- AND builder_workers.external_type != "cf_internal"

