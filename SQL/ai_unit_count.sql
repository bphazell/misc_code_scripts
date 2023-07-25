WITH unit_times AS (
SELECT u.id, u.job_id, MAX(j.created_at) as last_jud
FROM builder_units u
JOIN public.builder_judgments j on j.unit_id = u.id
WHERE u.state = 9
AND j.created_at > '2015-07-01'
GROUP BY u.id, u.job_id
)

SELECT a.id as team_id, a.name,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN  '2015-08-31' AND '2015-10-01' THEN unit_times.id END)) as since_sept
FROM builder_jobs j
JOIN unit_times ON unit_times.job_id = j.id
JOIN akon_teams a ON j.team_id = a.id
-- UPDATE TEAM ID HERE 
WHERE a.id IN ('e0b11cf2-cd70-4f5e-8ed9-001b95a633fb')
AND (j.title LIKE '%Twitter%' OR j.title LIKE '%Sentiment%')
AND j.state IN (2,3,4,5)
GROUP BY a.id, a.name

-- SELECT a.id as team_id, a.name, j.title, MAX(j.id),
--   COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN  '2015-09-01' AND '2015-09-30' THEN unit_times.id END)) as since_sept
-- FROM builder_jobs j
-- JOIN unit_times ON unit_times.job_id = j.id
-- JOIN akon_teams a ON j.team_id = a.id
-- -- UPDATE TEAM ID HERE 
-- WHERE a.id IN ('e0b11cf2-cd70-4f5e-8ed9-001b95a633fb')
-- AND (j.title LIKE '%Twitter%' OR j.title LIKE '%Sentiment%')
-- AND j.state IN (2,3,4,5)
-- GROUP BY a.id, a.name, j.title