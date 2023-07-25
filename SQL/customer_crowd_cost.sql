Select Sum(amount), job_id
From conversions
Where job_id in

(Select id
From jobs
Where user_id = 37083) 

AND
finished_at > '2014-03-25'
Group by job_id
LIMIT 100