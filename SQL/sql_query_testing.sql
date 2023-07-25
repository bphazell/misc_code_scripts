SELECT builder_organizations.project_number as builder_organizations_pn, builder_jobs.project_number as builder_jobs_pn, 
						builder_organizations.id as organization_id, akon_teams.name as team_name, akon_teams.id as team_id, 
				  team_member_info.user_id as akon_user_id, 
						builder_users.id as builder_user_id, builder_users.email as email, builder_jobs.id as job_id, markup_info.launch_date, 
						conversion_info.conversion_sum as job_cost, markup_info.markup, unit_total.unit_count,
						conversion_info.last_conversion as last_conversion
					FROM builder_organizations
					JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
					JOIN (SELECT DISTINCT(akon_team_memberships.user_id), akon_team_memberships.team_id
					    FROM akon_team_memberships)
					    AS team_member_info ON team_member_info.team_id = akon_teams.id
					JOIN builder_users on builder_users.akon_id = team_member_info.user_id
					JOIN builder_jobs on builder_jobs.user_id = builder_users.id
					JOIN (Select MAX(builder_conversions.started_at) as last_conversion, builder_conversions.job_id, ROUND(SUM(builder_conversions.amount),3) as conversion_sum
            FROM builder_conversions
            WHERE external_type != 'cf_internal'
            GROUP BY builder_conversions.job_id) AS conversion_info
            ON builder_jobs.id = conversion_info.job_id
					JOIN (SELECT max(builder_orders.markup) as markup, builder_orders.job_id, MIN(builder_orders.created_at) as launch_date
					     FROM builder_orders
					     WHERE builder_orders.type = 'Debit'
					     GROUP BY job_id)
					     AS markup_info on markup_info.job_id = builder_jobs.id
					JOIN (SELECT COUNT(builder_units.id) as unit_count, builder_units.job_id
					      FROM builder_units
					      Where builder_units.state = 9
					      GROUP BY builder_units.job_id)
					      AS unit_total ON unit_total.job_id = builder_jobs.id
					WHERE builder_organizations.project_number = 'PN447'
							AND conversion_info.last_conversion >= '2014-10-31'
					ORDER BY builder_users.id ASC	
					
-- account for jobs wihtout an owner
-- select sum(amount)
-- from builder_conversions
-- where job_id IN (
--   select id
--   from builder_jobs
--   where project_number = 'PN1092'
--   )
-- and finished_at >= '2014-01-01'