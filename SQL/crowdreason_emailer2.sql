SELECT builder_jobs.id AS job_id,
		builder_jobs.title AS job_title,
		builder_jobs.state AS job_state,
		payments.paid_amt AS job_cost,
		unit_info.row_count AS rows_finalized,
		order_info.order_amount AS order_amount,
		builder_jobs.project_id as project_id,
		(CASE builder_jobs.project_id WHEN 2821 THEN 'iMerit POC' END) as project
FROM builder_jobs
JOIN (SELECT ROUND((SUM(builder_conversions.amount)*1.2)::FLOAT,2) as paid_amt, builder_conversions.job_id
      FROM builder_conversions
      WHERE builder_conversions.created_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
      GROUP BY builder_conversions.job_id) as payments ON builder_jobs.id = payments.job_id
JOIN (SELECT count(distinct(builder_units.id)) AS row_count, builder_units.job_id
			FROM builder_units
			WHERE builder_units.state NOT IN (1,6,7,8)
			AND builder_units.updated_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
			GROUP BY builder_units.job_id) AS unit_info ON builder_jobs.id = unit_info.job_id
JOIN (SELECT SUM(builder_orders.amount_in_cents) AS order_amount, builder_orders.job_id
		FROM builder_orders
		WHERE builder_orders.created_at BETWEEN (CURRENT_DATE - INTERVAL '7 DAYS') AND CURRENT_DATE
		GROUP BY builder_orders.job_id) AS order_info ON builder_jobs.id = order_info.job_id
WHERE builder_jobs.team_id = '8888b0ab-1855-459f-8521-a7a3cc8f3622'
ORDER BY builder_jobs.id ASC