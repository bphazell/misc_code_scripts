  SELECT a.id, a.name, j.title,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-09-01' AND '2015-09-30' THEN c.amount END),2) as since_sept
  FROM builder_conversions c
  JOIN builder_jobs j ON j.id = c.job_id
  JOIN akon_teams a ON j.team_id = a.id
  Where c.created_at > '2015-01-01'
  -- Input Team ID Here:
  AND a.id = '1f466aa8-e83d-482e-b5b6-41330d074c04'
  AND (j.title LIKE '%Rate How Relevant These System Responses Are%' OR j.title LIKE '%Are These Commands Correct For The Given Scenario%'
                OR j.title LIKE '%Help Us Classify Tv Related Sentences%' OR j.title LIKE '%Are These Realistic Voice Commands %') 
  GROUP BY a.id, a.name, j.title