# NOT accurate
#shoulb be using Max(builder_judgments.created_at)
# side note: Having can be usesd as a replacement to where with aggregation?


SELECT date_trunc('month',started_at) as month, builder_jobs.project_number, COUNT(DISTINCT(builder_units.id)) as unit_count
FROM pn_list
JOIN builder_jobs 
	ON builder_jobs.project_number = pn_list.pn
JOIN builder_units
    ON builder_units.job_id = builder_jobs.id
JOIN builder_judgments
    ON builder_judgments.unit_id = builder_units.id
WHERE builder_units.state = 9
  AND builder_judgments.started_at >= '2014-01-01'
  AND builder_judgments.started_at < '2015-01-01'
GROUP BY builder_jobs.project_number, month
ORDER BY builder_jobs.project_number