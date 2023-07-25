-- top 10 products viewed for 

with high_value_visitors as (
  select 
    "visitor - id", 
    "visitor - metric - lifetime value - online"
  from "visitors_view_normalized"
  where "visitor - metric - lifetime value - online" > 1000
  order by "visitor - metric - lifetime value - online" DESC
  )
  
select 
  "visitor tally - product pageviews - key", 
  SUM("visitor tally - product pageviews - value") as view_count
from visitors_view_normalized vvn 
JOIN visitor_tallies_view_normalized vtn ON vtn."visitor - id" = vvn."visitor - id"
Where "visitor tally - product pageviews - key" is not null
group by "visitor tally - product pageviews - key"
order by view_count DESC
LIMIT 10
