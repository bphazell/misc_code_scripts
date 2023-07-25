SELECT pn_list.pn AS pn,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-12-01' AND '2015-01-01' THEN builder_units.id END)) AS december_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-11-01' AND '2014-12-01' THEN builder_units.id END)) AS november_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-10-01' AND '2014-11-01' THEN builder_units.id END)) AS october_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-09-01' AND '2014-10-01' THEN builder_units.id END)) AS september_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-08-01' AND '2014-09-01' THEN builder_units.id END)) AS august_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-07-01' AND '2014-08-01' THEN builder_units.id END)) AS july_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-06-01' AND '2014-07-01' THEN builder_units.id END)) AS june_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-05-01' AND '2014-06-01' THEN builder_units.id END)) AS may_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-04-01' AND '2014-05-01' THEN builder_units.id END)) AS april_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-03-01' AND '2014-04-01' THEN builder_units.id END)) AS march_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-02-01' AND '2014-03-01' THEN builder_units.id END)) AS february_14,
       COUNT(DISTINCT(CASE WHEN unit_final.last_update BETWEEN '2014-01-01' AND '2014-02-01' THEN builder_units.id END)) AS january_14,
       COUNT(DISTINCT(builder_units.id)) AS total
FROM builder_units
JOIN
  (SELECT unit_id, max(builder_judgments.created_at) as last_update
  FROM builder_judgments
  INNER JOIN builder_units ON builder_judgments.unit_id = builder_units.id
  WHERE builder_units.state = 9
  AND builder_judgments.created_at > '2014-01-01'
  GROUP BY unit_id) as unit_final
  ON unit_final.unit_id = builder_units.id
JOIN builder_jobs
  ON builder_jobs.id = builder_units.job_id
JOIN builder_users
  ON builder_users.id = builder_jobs.user_id
JOIN akon_team_memberships
  ON akon_team_memberships.user_id = builder_users.akon_id
JOIN akon_teams
  ON akon_team_memberships.team_id = akon_teams.id
JOIN pn_list
  ON builder_jobs.project_number = pn_list.pn
WHERE builder_units.updated_at >= '2014-01-01'
AND builder_units.state = 9
GROUP BY pn_list.pn
HAVING COUNT(DISTINCT(builder_units.id)) > 1
ORDER BY december_14 DESC
LIMIT 100