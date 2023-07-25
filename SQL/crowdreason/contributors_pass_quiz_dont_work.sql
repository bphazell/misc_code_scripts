SELECT count(distinct builder_worksets.id)
FROM builder_worksets
INNER JOIN goldfinger_evaluations
  ON (goldfinger_evaluations.job_id = builder_worksets.job_id 
    AND goldfinger_evaluations.worker_id = builder_worksets.worker_id)
WHERE builder_worksets.job_id = 608299
AND judgments_count = 5
AND worker_mode != 'quiz_expelled'
-- AND builder_worksets.worker_id NOT IN
-- (SELECT worker_id FROM goldfinger_gold_judgments
-- WHERE job_id = 608299
-- AND worker_mode = 'work'
-- AND state != 'pending')