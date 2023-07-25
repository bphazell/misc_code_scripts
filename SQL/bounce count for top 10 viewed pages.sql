WITH top_ten_pages AS (
  SELECT 
    "udo_page_name", 
    COUNT("udo_page_name") AS page_view_count,
    (SUM(CASE 
      WHEN "firstpartycookies_utag_main__ss" = 1 Then 1
      Else 0
      END)) as entrance_count
  FROM "events__all_events"
  GROUP BY "udo_page_name"
  ORDER BY page_view_count DESC
  LIMIT 10

),

 event_count_per_visit AS (

     SELECT
           "firstpartycookies_utag_main_ses_id",
           COUNT("eventid") AS event_count     
    FROM "events__all_events"
    WHERE "firstpartycookies_utag_main_ses_id" IS NOT NULL
    GROUP BY "firstpartycookies_utag_main_ses_id"
    ),
    
  bounced_sessions as (
  
    SELECT
       ee.eventid,
       ecv.event_count,
       ee.firstpartycookies_utag_main_ses_id,
       ee.udo_page_name
    FROM events__all_events ee
    JOIN event_count_per_visit ecv ON ecv.firstpartycookies_utag_main_ses_id = ee.firstpartycookies_utag_main_ses_id
    JOIN top_ten_pages ttp on ttp.udo_page_name = ee.udo_page_name
    where ee.udo_page_name is not null
    and event_count = 1
    ORDER BY firstpartycookies_utag_main_ses_id
    ),
    
bounce_count_per_page as ( 
  select 
    udo_page_name,
    count(eventid) as bounce_count
  from bounced_sessions
  group by udo_page_name
  order by bounce_count DESC
  )
 
 select 
  bcp.udo_page_name, 
  bcp.bounce_count,
  ((bcp.bounce_count::numeric / page_view_count::numeric)*100) as bounce_perc,
  page_view_count, 
  entrance_count
 from top_ten_pages ttp
 join bounce_count_per_page bcp on bcp.udo_page_name = ttp.udo_page_name
 order by bounce_count DESC




