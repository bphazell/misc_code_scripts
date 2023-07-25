
select DATE_TRUNC('hour', "eventtime") as hour,
       count (distinct("visitorid")) as visitor_count
from "events__all_events"
where "eventtime" > current_date - interval '7 days'
group by hour
order by hour ASC
