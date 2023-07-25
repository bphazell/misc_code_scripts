select
  ee."visitorid",
  ee."firstpartycookies_utag_main_ses_id",
  count(ee."eventid") as event_id
from "events__all_events" ee
-- where ee."visitorid" = '14f188f35792417f82722dd0e21d2710'
group by ee."visitorid", ee."firstpartycookies_utag_main_ses_id"
LIMIT 300


-- visitor c2eb643e0e4c42079890325881adf385
--visit 258f082d6889eef861f2e4f00016c84ead9a8dde9da370341b738969ed12181a

-- select 
--   vv."visit - id",
--   count(ee."eventid") as event_count
-- from "events__all_events" ee
-- JOIN "visitor_replaces_view" vrv on vrv."visitor - replaces id" = ee."visitorid"
-- JOIN "visits_view" vv on vv."visit - visitor id" = vrv."visitor - id"
-- group by vv."visit - id"
-- LIMIT 100
