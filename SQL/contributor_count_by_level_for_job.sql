with max_level as (
  SELECT worker_skills.worker_id, MAX(worker_skills.skill_id) as max_id
  FROM worker_skills
  WHERE worker_skills.skill_id IN (259, 260, 261)
  GROUP BY worker_skills.worker_id
) 

SELECT worker_skills.name, count(builder_worksets.worker_id)
FROM builder_worksets
JOIN max_level on max_level.worker_id = builder_worksets.worker_id
JOIN worker_skills on (worker_skills.skill_id = max_level.max_id AND worker_skills.worker_id = max_level.worker_id)
WHERE builder_worksets.job_id = 717902
AND builder_worksets.judgments_count > 5
group by worker_skills.name

-- SELECT builder_worksets.job_id,
--       COUNT(CASE WHEN max_level.max_id = 259 THEN max_level.worker_id END) AS level1,
--       COUNT(CASE WHEN max_level.max_id = 260 THEN max_level.worker_id END) AS level2,
--       COUNT(CASE WHEN max_level.max_id = 261 THEN max_level.worker_id END) AS level3
-- FROM builder_worksets
-- JOIN max_level on builder_worksets.worker_id = max_level.worker_id
-- WHERE builder_worksets.job_id = 717902
-- AND builder_worksets.judgments_count > 5
-- GROUP BY builder_worksets.job_id



