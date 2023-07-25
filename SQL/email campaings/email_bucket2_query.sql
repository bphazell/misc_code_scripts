SELECT   
FROM pn_list
JOIN 
   (SELECT builder_users.email,
          job_data.job_id,
          job_data.project_number,
          job_data.created_at,
          job_data.fin_unit,
          job_data.gold_unit,
          job_data.total_jud,
          job_data.total_trusted_jud,
          ROUND((CAST((job_data.total_jud - job_data.total_trusted_jud) as numeric)
                 / CAST(job_data.total_jud as numeric)) * 100 , 1)  as untrusted_ratio
   From builder_users
   JOIN
      (select builder_jobs.id as job_id,
              builder_jobs.project_number,
              builder_jobs.created_at,
              builder_jobs.user_id,
              COUNT(DISTINCT(CASE WHEN unit_data.state = 9 THEN unit_data.unit_id END)) AS fin_unit,
              COUNT(DISTINCT(CASE WHEN unit_data.state = 6 THEN unit_data.unit_id END)) as gold_unit,
              SUM(CASE WHEN unit_data.state = 9 OR unit_data.state = 2 or unit_data.state = 3 THEN unit_data.judgments_count END) as total_jud,
              SUM(CASE WHEN unit_data.state = 9 OR unit_data.state = 2 or unit_data.state = 3 THEN unit_data.number_of_accurate_judgments END) as total_trusted_jud
      FROM builder_jobs
      JOIN
          (SELECT builder_units.id as unit_id,
                  builder_units.state,
                  builder_units.judgments_count, 
                  builder_units.number_of_accurate_judgments,  
                  builder_units.job_id
          from builder_units
          WHERE builder_units.state = 9
            OR builder_units.state = 6
            OR builder_units.state = 2
            OR builder_units.state = 3) as unit_data
       ON builder_jobs.id = unit_data.job_id
      GROUP BY builder_jobs.id, builder_jobs.project_number, builder_jobs.created_at, builder_jobs.user_id
      ORDER BY builder_jobs.id DESC) as job_data
  ON job_data.user_id = builder_users.id
  WHERE job_data.fin_unit > 25)
