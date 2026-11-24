select distinct r.reviewer_id, au.given_name, au.surname, au.email 
from reviewer r 
join reviewer_expertise re 
on r.reviewer_id  = re.reviewer_id 
join app_user au 
on au.user_id = r.reviewer_id  
join conference_reviewer cr 
on cr.reviewer_id = r.reviewer_id 
where r.years_experience >= 3 and re.area_label = 'Databases' and cr.conference_id = 1;