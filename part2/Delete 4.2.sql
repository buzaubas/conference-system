delete from conference_session 
where session_id in 
(select cs.session_id  
from conference_session cs 
natural join conference c
where c.city = 'Astana' and 
cs.session_id not in (select con.session_id from conference_session con join paper pap on con.session_id = pap.session_id ));

