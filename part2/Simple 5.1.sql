select p.paper_id, p.title, au.given_name, au.surname, au.email, t.name, t.conference_id, c.acronym
from paper p
join paper_author pa 
on p.paper_id = pa.paper_id 
join author a 
on pa.author_id = a.author_id 
join app_user au 
on au.user_id = a.author_id 
join track t 
on p.track_id = t.track_id 
join conference c 
on t.conference_id = c.conference_id
where p.status = 'accepted' and pa.is_corresponding = true;