select 
  SUM(CASE WHEN
        "visitor - audience - visitors - known" = true then 1
        ELSE 0
        END) as known_visitors,
  Count("visitor - id") as total_visitors,
  ((known_visitors::numeric / total_visitors)* 100) as perc_known
from visitors_view_normalized


-- OR -- 


select 
  count(vvn."visitor - id") as total_visitor_count, 
  SUM(
      CASE 
          WHEN vrv."visitor - id" IS NOT NULL THEN 1
          ELSE 0
          END) as known_visitor_count,
  ((known_visitor_count::numeric / total_visitor_count::numeric) * 100) as known_perc
from visitors_view_normalized vvn
LEFT JOIN visitor_replaces_view vrv ON vvn."visitor - id" = vrv."visitor - id"