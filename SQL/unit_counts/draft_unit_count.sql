WITH unit_times AS (
  SELECT u.id, u.job_id, MAX(j.created_at) as last_jud
  FROM builder_units u
  JOIN public.builder_judgments j on j.unit_id = u.id
  WHERE u.state = 9
  AND j.created_at > '2015-01-01'
  GROUP BY u.id, u.job_id
)

SELECT a.id as team_id, a.name,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-01-01' AND '2015-01-031' THEN unit_times.id END)) as jan15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-02-01' AND '2015-02-28' THEN unit_times.id END)) as feb15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-03-01' AND '2015-03-31' THEN unit_times.id END)) as mar15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-04-01' AND '2015-04-30' THEN unit_times.id END)) as apr15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-05-01' AND '2015-05-31' THEN unit_times.id END)) as may15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-06-01' AND '2015-06-30' THEN unit_times.id END)) as jun15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-07-01' AND '2015-07-31' THEN unit_times.id END)) as july15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-08-01' AND '2015-08-31' THEN unit_times.id END)) as aug15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-09-01' AND '2015-09-30' THEN unit_times.id END)) as sep15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-10-01' AND '2015-10-31' THEN unit_times.id END)) as oct15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-11-01' AND '2015-11-30' THEN unit_times.id END)) as nov15,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2015-12-01' AND '2015-12-31' THEN unit_times.id END)) as dec15
FROM builder_jobs j
JOIN unit_times ON unit_times.job_id = j.id
JOIN akon_teams a ON j.team_id = a.id
-- UPDATE TEAM ID HERE 
WHERE a.id IN ('d498ff27-ab9a-4e15-bf3b-ff08959a3650')
GROUP BY a.id, a.name
