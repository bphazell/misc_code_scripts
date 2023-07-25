
select "udo_page_name", count("udo_page_name") as page_view_count
from "events__all_events"
where "firstpartycookies_utag_main__ss" = 1
group by "udo_page_name"
order by page_view_count DESC 
LIMIT 10