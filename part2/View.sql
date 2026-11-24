--Create a database view named accepted_paper_schedule. It must return one row per paper assigned 
--to a session, with the paper ID and title, conference ID and acronym, track name, session ID and title, 
--session date, start and end times, room label, chair’s full name, and corresponding author’s full name 
--and email. Accepted papers without a session must not appear in this view. 
--Query the view and order the output by conference ID, session date, start time, session ID, and paper 
--ID. Do not store a separate copy of the query result as a table. 


create or replace view accepted_paper_schedule as
select p.paper_id, p.title as paper_title, cs.conference_id, c.acronym, t."name", 
			cs.session_id, cs.title as session_title, cs.session_date, cs.start_time, cs.end_time, cs.room_label, 
			concat(au.given_name, ' ', au.surname) as chair_fullname,
			concat(aua.given_name, ' ', aua.surname) as author_fullname, aua.email as author_email
from paper p 
join conference_session cs 
on p.session_id = cs.session_id
join conference c 
on cs.conference_id = c.conference_id
join track t 
on p.track_id  = t.track_id  
join reviewer r 
on cs.chair_id = r.reviewer_id 
join app_user au 
on r.reviewer_id = au.user_id 
join paper_author pa 
on p.paper_id = pa.paper_id 
join author a 
on pa.author_id = a.author_id 
join app_user aua
on a.author_id = aua.user_id 
where pa.is_corresponding = true and p.status = 'accepted';

SELECT *
FROM accepted_paper_schedule
order by conference_id, session_date, start_time, session_id, paper_id;

