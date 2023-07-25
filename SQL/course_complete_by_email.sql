with new_course_complete_count as (
  select 
    "visitorid",  
    "udo_tealium_event",
    count("eventid") as "event_count"
  from "events__all_events"
  WHERE "udo_tealium_event" = 'new course complete'
  GROUP BY "udo_tealium_event", "visitorid"
  Order by event_count desc
)

select vvn."visitor - property - user email", new_course."udo_tealium_event", new_course."event_count"
from "visitors_view_normalized" vvn
JOIN new_course_complete_count new_course ON vvn."visitor - id" = new_course."visitorid"
where new_course."event_count" > 5
order by new_course."event_count" DESC
LIMIT 200
