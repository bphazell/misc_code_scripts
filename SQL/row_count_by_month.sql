 WITH unit_times AS (
SELECT u.id, u.job_id, MAX(j.created_at) as last_jud
FROM builder_units u
JOIN public.builder_judgments j on j.unit_id = u.id
WHERE u.state IN (2,3,4,8,9)
AND j.created_at > '2016-01-01'
GROUP BY u.id, u.job_id
)

SELECT a.id as team_id, a.name,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-01-01' AND '2016-02-01' THEN unit_times.id END)) as jan16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-02-01' AND '2016-03-01' THEN unit_times.id END)) as feb16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-03-01' AND '2016-04-01' THEN unit_times.id END)) as mar16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-04-01' AND '2016-05-01' THEN unit_times.id END)) as apr16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-05-01' AND '2016-06-01' THEN unit_times.id END)) as may16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-06-01' AND '2016-07-01' THEN unit_times.id END)) as june16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-07-01' AND '2016-08-01' THEN unit_times.id END)) as jul16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-08-01' AND '2016-09-01' THEN unit_times.id END)) as aug16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-09-01' AND '2016-10-01' THEN unit_times.id END)) as sep16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-10-01' AND '2016-11-01' THEN unit_times.id END)) as oct16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-11-01' AND '2016-12-01' THEN unit_times.id END)) as nov16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-12-01' AND '2017-01-01' THEN unit_times.id END)) as dec16,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2017-01-01' AND '2017-02-01' THEN unit_times.id END)) as jan17,
  COUNT(DISTINCT(CASE WHEN unit_times.last_jud BETWEEN '2016-01-01' AND '2017-02-01' THEN unit_times.id END)) as Total
FROM builder_jobs j
JOIN unit_times ON unit_times.job_id = j.id
JOIN akon_teams a ON j.team_id = a.id
-- UPDATE TEAM ID HERE 
WHERE a.id IN ('d498ff27-ab9a-4e15-bf3b-ff08959a3650')
AND ((j.title LIKE '%Classification%')
OR (j.title LIKE '%Chronicle%'))
GROUP BY a.id, a.name

