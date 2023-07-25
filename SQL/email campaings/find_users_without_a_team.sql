SELECT email,
  first_name,
  last_name,
  akon_id,
  project_number,
  team_id,
  name AS team_name,
  REGEXP_SUBSTR( builder_users.email , '@.+') AS email_domain
FROM builder_users
LEFT JOIN akon_team_memberships ON builder_users.akon_id = akon_team_memberships.user_id
LEFT JOIN akon_teams ON akon_team_memberships.team_id = akon_teams.id
WHERE (team_id IS NULL OR akon_teams.name = email)
    AND email NOT LIKE '%crowdflower.com'
    AND email NOT LIKE '%hotmail.com'
    AND email NOT LIKE '%yahoo.com'
    AND email NOT LIKE '%@me.com'
    AND email NOT LIKE '%@gmail.com'
    AND email NOT LIKE '%@outlook.com'
    AND email NOT LIKE '%stanford.edu'
AND builder_users.created_at > '01-01-2012'
AND REGEXP_SUBSTR( builder_users.email , '@.+') IN (
    SELECT DISTINCT REGEXP_SUBSTR( builder_users.email , '@.+')
    FROM pn_list
    JOIN akon_team_memberships
        ON pn_list.team_id = akon_team_memberships.team_id
    JOIN builder_users
        ON builder_users.akon_id = akon_team_memberships.user_id
    WHERE pn_list.pn != 'PN1403'
    AND pn_list.pn != 'PN1385'
    AND first_name != 'Dougtest')
  