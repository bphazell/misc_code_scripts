   SELECT pn_list.pn, 
          builder_users.email, 
          builder_users.first_name, 
          builder_users.last_name, 
          unit_count_per_user.unit_count as unit_count_per_user, 
          builder_users.created_at
     From pn_list
      JOIN builder_users
      ON builder_users.project_number = pn_list.pn
      FULL JOIN
          (SELECT SUM(unit_counts_per_job.unit_count) AS unit_count, 
                  builder_jobs.user_id AS jobs_uid
          FROM builder_jobs 
          JOIN 
                (SELECT count(builder_units.id) AS unit_count, 
                        builder_units.job_id AS job_id
                FROM builder_units
                WHERE builder_units.state = 9
                GROUP BY builder_units.job_id) AS unit_counts_per_job
            ON builder_jobs.id = unit_counts_per_job.job_id
          GROUP BY jobs_uid) AS unit_count_per_user 
        ON builder_users.id = unit_count_per_user.jobs_uid
      WHERE (unit_count_per_user.unit_count < 100 
            OR builder_users.id NOT IN (
                                select builder_users.id
                                from pn_list
                                join builder_users on builder_users.project_number = pn_list.pn
                                JOIN builder_jobs on builder_jobs.user_id = builder_users.id)
                                )
       AND builder_users.created_at < '2015-06-01'
      ORDER BY pn_list.pn