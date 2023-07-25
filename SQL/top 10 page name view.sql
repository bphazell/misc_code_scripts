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
