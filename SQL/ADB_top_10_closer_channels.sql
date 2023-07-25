select
  "visitor - property - channel closer",
  count("visitor - id") as visitor_count
from "visitors_view_normalized"
where "visitor - property - channel closer" is not null
group by "visitor - property - channel closer"
order by visitor_count DESC

