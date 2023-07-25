WITH visitors AS (
  SELECT 
     visitors."visitor - id", 
     v_replaces."visitor - replaces id",
     visitors."visitor - property - user email", 
     visitors."visitor - property - user company", 
     visitors."visitor - property - user email (end of visit)",
     visitors."visitor - property - user email (previous)"
  FROM
    visitors_view_normalized visitors
  JOIN visitor_replaces_view v_replaces ON v_replaces."visitor - id" = visitors."visitor - id"
  Where visitors."visitor - property - user email" IS NOT NULL
  AND visitors."visitor - id" = '__tealium_education__5080_talent-662__'
  ), 
  
last_visit AS (
  SELECT 
    "visit - id",
    "visit - visitor id",
    MAX("visit - start time") AS "visit_start_time",
    "visit - last event time",
    "visit - property - active browser type (44)",
    "visit - property - active browser version (48)",
    "visit - property - active device (46)",
    "visit - property - active operating system (45)",
    "visit - property - active platform (47)",
    "visit - flag - certification score change (as) (5088)",
    "visit - flag - certification score change (da) (5115)",
    "visit - flag - certification score change (es) (5117)",
    "visit - flag - certification score change (iq) (5119)",
    "visit - flag - direct visit (14)",
    "visit - property - entry url (5)",
    "visit - metric - event count (7)",
    "visit - property - exit url (6)",
    "visit - flag - referred visit (13)",
    "visit - metric - visit duration (12)",
    "visit - date - visit end (11)",
    "visit - date - visit start (10)"
  FROM visits_view
  GROUP BY 
    "visit - id",
    "visit - visitor id",
    "visit - last event time",
    "visit - property - active browser version (48)",
    "visit - property - active device (46)",
    "visit - property - active operating system (45)",
    "visit - property - active platform (47)",
    "visit - property - active browser type (44)",
    "visit - flag - certification score change (as) (5088)",
    "visit - flag - certification score change (da) (5115)",
    "visit - flag - certification score change (es) (5117)",
    "visit - flag - certification score change (iq) (5119)",
    "visit - flag - direct visit (14)",
    "visit - property - entry url (5)",
    "visit - metric - event count (7)",
    "visit - property - exit url (6)",
    "visit - flag - referred visit (13)",
    "visit - metric - visit duration (12)",
    "visit - date - visit end (11)",
    "visit - date - visit start (10)"
 )
 
select *
from last_visit
JOIN visitors ON visitors."visitor - id" = last_visit."visit - visitor id"

