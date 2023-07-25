WITH events_per_session AS (
    SELECT
           "firstpartycookies_utag_main_ses_id",
           COUNT("eventid") AS event_count     
    FROM "events__all_events"
    WHERE "firstpartycookies_utag_main_ses_id" IS NOT NULL
    GROUP BY "firstpartycookies_utag_main_ses_id"
    ),
 
bounce_counts AS (
   SELECT 
    SUM(CASE WHEN "event_count" = 1 THEN 1
         ELSE 0
         END )as bounced_session,
    COUNT("event_count")AS total_sessions
  FROM events_per_session
  )

SELECT ((bounced_session::numeric / total_sessions::numeric)*100) as bounce_perc
FROM bounce_counts
