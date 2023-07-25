select count(id)
FROM worker_ui_assignments
WHERE worker_ui_assignments.finished_at >= '2015-05-01'
AND length(worker_ui_assignments.gold_unit_ids) < 15
AND worker_ui_assignments.finished_at IS NOT NULL
AND worker_ui_assignments.job_id = 608299