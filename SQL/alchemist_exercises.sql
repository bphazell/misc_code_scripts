


-- Problem Set 1

-- 1A) Return all launched job id’s, job titles, and date created, and job state for Amex team. 
-- 1B) For the job state,  replace the numerical value with text. Order jobs by date created. 
		select id, title, created_at, replace(
		                  replace(
		                  replace(state, 2, 'Runnin'), 3, 'Paused'), 5,'Finished')as state
		from public.builder_jobs 
		where team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
		and state in (2, 3, 5)
		Order by created_at DESC


-- 2A)  Return all “unique” job titles associated with a user’s email (american.express@crowdflower.com). Return the unique job id and users email. Order jobs by apphabetical order. 

		select j.title, u.email
		from builder_users u
		join builder_jobs j on j.user_id = u.id
		where u.email = 'american.express@crowdflower.com'
		group by j.title, u.email
		order by j.title ASC


-- 2B  Return the count of jobs for each unique job title. Order by highest to lowest count. 

	
		select j.title, u.email, count(j.id) as count
		from builder_users u
		join builder_jobs j on j.user_id = u.id
		where u.email = 'american.express@crowdflower.com'
		group by j.title, u.email
		order by count DESC



-- 3)  Return all unique contributor 'worker ids’ that worked in a job 990727. Order by worke_id descending. Return team id and job id. 

		select Distinct worker_id, job_id
		from public.builder_worksets 
		where job_id = 990727


-- 4)  Return all unique contributor ’akon ids’ that have worked in any of a American Express Team's jobs. Return akdn id and team id, order by akon id descending. 

		select DISTINCT wrk.user_id, j.team_id
		from public.builder_worksets w
		join public.builder_jobs j on j.id = w.job_id
		join public.builder_workers wrk on wrk.id = w.worker_id
		where j.team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
		order by wrk.user_id


-- Problem Set 2

-- 5)  Count # of finalized, judable, new and test question rows in a job 990727

	select job_id, 
	    count(case when state = 1 then id end) as New,
	    count(case when state = 2 then id end) as Judgable,
	    count(case when state = 9 then id end) as Finalized,
	    count(case when state = 6 then id end) as Test_Question
	from public.builder_units 
	where job_id = 990727
	group by job_id

				-- or

	select job_id, count(id), state
	from public.builder_units 
	where job_id = 990727
	group by job_id, state


-- 6)  Compute the total cost of a job # include job with markup (make sure to include markup)

		select j.id, (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as cost
		from builder_conversions c
		join public.builder_jobs j on j.id = c.job_id
		where j.id = 982788
		group by j.id, j.markup



-- 7)  Total crowd cost for team past 3 months

		select j.team_id, j.markup, (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as cost
		from builder_conversions c
		join public.builder_jobs j on j.id = c.job_id
		where j.team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
		and c.created_at >= DATEADD(MONTH, -3, GETDATE()) 
		group by j.team_id, j.markup


-- 8)  Total units run for team for past 3 months

		select j.team_id, count(u.id)
		from builder_units u 
		join public.builder_jobs j on j.id = u.job_id
		where j.team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
		and u.state IN (2, 3, 4, 5, 9)
		and u.created_at >= DATEADD(MONTH, -3, GETDATE()) 
		group by j.team_id


-- Problem Set 3

-- 9)  Total crowd cost for team past 3 months per month

		select j.team_id, j.markup, date_trunc('month', c.created_at) AS "month", (sum(c.amount) + (sum(c.amount) * (j.markup::numeric / 100))) as cost
		from builder_conversions c
		join public.builder_jobs j on j.id = c.job_id
		where j.team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
		and c.created_at >= DATEADD(MONTH, -3, GETDATE()) 
		group by j.team_id, j.markup, month

-- 10) Total units run for team for past 3 months per month

	select j.team_id, date_trunc('month', u.created_at) AS month, count(u.id)
	from builder_units u 
	join public.builder_jobs j on j.id = u.job_id
	where j.team_id = 'c7a445b2-dcce-431e-8719-d358edc0cadf'
	and u.state IN (2, 3, 4, 5, 9)
	and u.created_at >= DATEADD(MONTH, -3, GETDATE()) 
	group by j.team_id, month

	-- Note: the more accurate way to is to use max jud as units created is just when it was uploaded, not completed

		WITH unit_times AS (
		SELECT u.id, u.job_id, MAX(j.created_at) as last_jud
		FROM builder_units u
		JOIN public.builder_judgments j on j.unit_id = u.id
		WHERE u.state = 9
		AND j.created_at > '2017-01-15'
		GROUP BY u.id, u.job_id
		)
		SELECT a.id as team_id, a.name, date_trunc('day', unit_times.last_jud) AS "day",
		  COUNT(unit_times.id) as total 
		FROM builder_jobs j
		JOIN unit_times ON unit_times.job_id = j.id
		-- UPDATE TEAM ID HERE 
		WHERE a.id IN ('d498ff27-ab9a-4e15-bf3b-ff08959a3650')
		AND j.state IN (2,3,4,5)
		GROUP BY a.id, a.name, day
		Order by day desc

-- 11) Number of trusted vs. untrusted judgments in  job 982788 (same difficulty as cost/units per month, it's a 'case when' type situation).

		select j.id,
		count(case when (ju.tainted = false and ju.golden = false) then ju.id end) as trusted,
		count(case when (ju.tainted = true and ju.golden = false) then ju.id end) as untrusted
		from public.builder_jobs j
		join public.builder_judgments ju on ju.job_id = j.id
		where j.id = 982788
		group by j.id




-- 12) First judgment, last judgment, time to completion for job 982788

		with judgments as (
		select max(created_at) as last_jud,
		min(started_at) as first_jud, unit_id
		from public.builder_judgments
		where job_id = 982788
		and golden = false
		group by unit_id),

		time as (
		select u.id, 
		SUM(DATEDIFF(seconds, u.created_at, j.last_jud)) AS total_seconds_completion,
		SUM(DATEDIFF(seconds, u.created_at, j.first_jud)) AS total_seconds_assign,
		SUM(DATEDIFF(seconds, j.first_jud, j.last_jud)) AS total_seconds_assign_to_complete
		from judgments j
		left join public.builder_units u on u.id = j.unit_id
		where job_id = 982788
		and u.state = 9
		group by u.id)


		select u.id, u.created_at as unit_upload, j.first_jud as first_jud_start, j.last_jud as last_jud_submit,
		t.total_seconds_assign AS upload_to_first_jud,
		t.total_seconds_completion AS upload_to_complete,
		t.total_seconds_assign_to_complete AS first_jud_to_complete
		from judgments j
		left join public.builder_units u on u.id = j.unit_id
		left join time t on t.id = j.unit_id
		where job_id = 982788
		and u.state = 9
		and u.created_at like '%2017-03-04%'
		group by u.id, u.created_at, j.last_jud, t.total_seconds_completion, j.first_jud, 
		t.total_seconds_assign, t.total_seconds_assign_to_complete






