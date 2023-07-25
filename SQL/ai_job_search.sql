  SELECT a.id, a.name, j.title, MAX(j.id),
  ROUND(SUM(c.amount ),2) as since_sept
  FROM builder_conversions c
  JOIN builder_jobs j ON j.id = c.job_id
  JOIN akon_teams a ON j.team_id = a.id
  Where c.created_at > '2015-07-01'
  -- Input Team ID Here:
  AND a.id = 'e0b11cf2-cd70-4f5e-8ed9-001b95a633fb'
  AND (j.title LIKE '%sentiment%' OR j.title LIKE '%Sentiment%' OR
  j.title LIKE '%Twitter%' OR j.title LIKE '%twitter%') 
  GROUP BY a.id, a.name, j.title
  ORDER BY j.title