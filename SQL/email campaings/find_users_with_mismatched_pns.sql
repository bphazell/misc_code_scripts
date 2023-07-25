select pn_list.pn as pn_list_pn,
      builder_organizations.project_number as build_org_pn,
      pn_list.org_name,
      pn_list.org_id,
      (builder_users.id),
      builder_organizations.markup,
      builder_plans.name as plan_name,
      (CASE 
        WHEN pn_list.org_id IN 
          (SELECT organization_id
          FROM akon_roles_organizations
          JOIN akon_roles ON akon_roles.id = akon_roles_organizations.role_id
          WHERE akon_roles.role_type_id = 47) THEN TRUE
        ELSE NULL
      END) as taxonomy_client
from pn_list
 JOIN akon_team_memberships
   ON pn_list.team_id = akon_team_memberships.team_id
 JOIN builder_users
   ON builder_users.akon_id = akon_team_memberships.user_id
 JOIN builder_organizations 
   ON builder_organizations.id = pn_list.org_id
 JOIN builder_plans
   ON builder_users.plan_id = builder_plans.id
WHERE pn_list.pn !=  builder_organizations.project_number
AND plan_name != 'trial'
AND plan_name != 'basic'
AND CAST(REGEXP_SUBSTR(pn,'[^PN].+') AS numeric) IN
           (SELECT MAX(CAST(REGEXP_SUBSTR(pn,'[^PN].+') AS numeric)) AS pn_number
           FROM pn_list
           GROUP BY org_name) 
order by org_name
      


