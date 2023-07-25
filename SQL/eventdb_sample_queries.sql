

-- Total Event Count
SELECT COUNT(eventid) FROM "events__all_events"
-- Unique Email Count
SELECT COUNT(DISTINCT udo_email) FROM "events__all_events"
-- Unique visitor status with a count of each
SELECT udo_status, COUNT(udo_status) FROM "events__all_events" group by udo_status