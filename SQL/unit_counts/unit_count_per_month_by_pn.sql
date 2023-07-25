SELECT date_trunc('month',started_at) as month, builder_jobs.project_number, COUNT(DISTINCT(builder_units.id)) as unit_count
FROM builder_jobs
JOIN builder_units
    ON builder_units.job_id = builder_jobs.id
JOIN builder_judgments
    On builder_judgments.unit_id = builder_units.id
where builder_jobs.project_number = 'PN781'
  AND builder_units.state = 9
  AND builder_judgments.started_at >= '2014-01-01'
  AND builder_judgments.started_at < '2015-01-01'
group by builder_jobs.project_number, month
