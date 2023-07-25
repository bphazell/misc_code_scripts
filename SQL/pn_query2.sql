SELECT builder_organizations.project_number as builder_organizations_pn, builder_jobs.project_number as builder_jobs_pn, 
akon_teams.name as team_name, builder_organizations.id as organization_id, akon_teams.id as team_id, 
builder_users.email as user_email, akon_team_memberships.user_id as akon_user_id, 
builder_users.id as builder_user_id, count(builder_jobs.id) as job_count, max(builder_conversions.started_at) as last_conversion
FROM builder_organizations
JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
JOIN akon_team_memberships on akon_team_memberships.team_id = akon_teams.id
JOIN builder_users on builder_users.akon_id = akon_team_memberships.user_id
JOIN builder_jobs on builder_jobs.user_id = builder_users.id
JOIN builder_conversions on builder_conversions.job_id = builder_jobs.id
WHERE builder_organizations.project_number = 'PN447'
AND builder_conversions.started_at >= '2013-11-01'
GROUP BY builder_organizations.project_number,builder_jobs.project_number, builder_organizations.id,akon_teams.name, akon_teams.id,
akon_teams.id,builder_users.id, akon_team_memberships.user_id,builder_users.email
LIMIT 10


/* cant link role_types_ to users, */
SELECT builder_organizations.project_number as builder_organizations_pn, builder_jobs.project_number as builder_jobs_pn, 
  akon_teams.name as team_name, builder_organizations.id as organization_id, akon_teams.id as team_id, 
  builder_users.email as user_email, akon_team_memberships.user_id as akon_user_id,   
  builder_users.id as builder_user_id, count(builder_jobs.id) as job_count, max(builder_conversions.started_at) as last_conversion,
  akon_roles_users.role_id as role_id
FROM builder_organizations
JOIN akon_teams on akon_teams.organization_id = builder_organizations.id
JOIN akon_team_memberships on akon_team_memberships.team_id = akon_teams.id
JOIN builder_users on builder_users.akon_id = akon_team_memberships.user_id
JOIN akon_roles_users on akon_roles_users.user_id = builder_users.akon_id
JOIN builder_jobs on builder_jobs.user_id = builder_users.id
JOIN builder_conversions on builder_conversions.job_id = builder_jobs.id
WHERE builder_organizations.project_number = 'PN1098'
  AND builder_conversions.started_at >= '2013-11-01'
GROUP BY builder_organizations.project_number,builder_jobs.project_number, builder_organizations.id,akon_teams.name, akon_teams.id,
  akon_teams.id,builder_users.id, akon_team_memberships.user_id,builder_users.email,akon_roles_users.role_id 
LIMIT 10


