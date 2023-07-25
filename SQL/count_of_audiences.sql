select 
  SUM(case
          when "visitor - audience - mens apparel fans" = true then 1
          else 0
          end
          ) as mens_fan_count,
  SUM(case
         when "visitor - audience - cart abandoners" = true then 1
         else 0
         end
         ) as cart_abandon_count,
  SUM(case
         when "visitor - audience - frequently refunded" = true then 1
         else 0
         end
         ) as freq_refunded_count,
  SUM(case
         when  "visitor - audience - consent tealium in" = true then 1
         else 0
         end
         ) as opt_in_count,
  SUM(case
         when   "visitor - audience - consent tealium out" = true then 1
         else 0
         end
         ) as opt_out_count
from "visitors_view_normalized" vvn
LIMIT 100
