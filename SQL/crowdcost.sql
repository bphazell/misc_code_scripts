SELECT a.id, a.name,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2014-11-01' AND '2014-12-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2014-11-01' AND '2014-12-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as nov14,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2014-12-01' AND '2015-01-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2014-12-01' AND '2015-01-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as dec14,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-01-01' AND '2015-02-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-01-01' AND '2015-02-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as jan15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-02-01' AND '2015-03-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-02-01' AND '2015-03-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as feb15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-03-01' AND '2015-04-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-03-01' AND '2015-04-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as mar15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-04-01' AND '2015-05-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-04-01' AND '2015-05-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as apr15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-05-01' AND '2015-06-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-05-01' AND '2015-06-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as may15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-06-01' AND '2015-07-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2015-06-01' AND '2015-07-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as jun15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-07-01' AND '2015-08-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as july15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-08-01' AND '2015-09-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as aug15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-09-01' AND '2015-10-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as sep15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-10-01' AND '2015-11-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as oct15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-11-01' AND '2015-12-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as nov15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-12-01' AND '2016-01-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as dec15,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-01-01' AND '2016-02-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as jan16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-02-01' AND '2016-03-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as feb16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-03-01' AND '2016-04-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as mar16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-04-01' AND '2016-05-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as apr16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-05-01' AND '2016-06-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as may16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-06-01' AND '2016-07-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as jun16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-07-01' AND '2016-08-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as jul16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as aug16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-09-01' AND '2016-10-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as sep16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-10-01' AND '2016-11-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2)as oct16,
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2016-11-01' AND '2016-12-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as nov16,
  
  ROUND(SUM(CASE WHEN c.created_at BETWEEN '2015-01-01' AND '2016-12-01' THEN c.amount END)+(sum(CASE WHEN c.created_at BETWEEN '2016-08-01' AND '2016-09-01' THEN c.amount END) * (j.markup::numeric / 100)),2) as Total
  FROM builder_conversions c
  JOIN builder_jobs j ON j.id = c.job_id
  JOIN akon_teams a ON j.team_id = a.id
  Where c.created_at > '2014-12-01'
  AND a.id IN ('d498ff27-ab9a-4e15-bf3b-ff08959a3650')
   AND ((j.title  LIKE '(%Classification%') 
    OR (j.title LIKE '%Chronicle%'))
  GROUP BY a.id, a.name, j.markup
