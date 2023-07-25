select 
  count("visit - id") as total_visit_count,
  SUM( CASE
        WHEN "visit - flag - had items in cart - visit (6480)" = true THEN 1
        ELSE 0
        END) as count_added_to_cart,
  SUM( CASE
        WHEN "visit - flag - did complete order (6476)" = true THEN 1
        ELSE 0
        END) as count_completed_order
from visits_view

