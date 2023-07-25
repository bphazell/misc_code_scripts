-- How many trusted test judgements have we paid for (post quiz)?

--join on workset not tainted use job id and worker id
--select builder_worksets.job_id, builder_worksets.worker_id, goldfinger_gold_judgments.worker_mode, gold_instance_id, tainted
select count(gold_instance_id)
from builder_worksets
INNER JOIN goldfinger_gold_judgments ON (goldfinger_gold_judgments.worker_id = builder_worksets.worker_id 
                                AND goldfinger_gold_judgments.job_id = builder_worksets.job_id)
where builder_worksets.job_id = 608299
and worker_mode = 'work'
AND state !='pending'
and tainted=FALSE
-- order by builder_worksets.worker_id
