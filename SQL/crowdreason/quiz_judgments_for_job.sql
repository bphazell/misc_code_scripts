-- How many trusted upfront quiz judgements have we paid for?

-- for other query
--join on workset not tainted use job id and worker id
--take first conversion of every job multipy 5
--people who passed quiz times 5
select (COUNT(id) * 5) as amount_trusted_quiz_judgements_paind
from builder_conversions
where id in
  (select min(id)
  from builder_conversions
  where job_id = 608299
  group by worker_id)


-- select *
-- from builder_worksets
-- where tainted = FALSE
-- AND job_id = 608299



