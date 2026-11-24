--For every conference, calculate its paper acceptance rate as a percentage: 100.0 multiplied by the 
--number of accepted papers, divided by the number of accepted plus rejected papers. Show 
--conference ID, acronym, accepted count, rejected count, and acceptance rate rounded to two decimal 
--places. Exclude submitted, under review, and withdrawn papers from the denominator. Return NULL 
--when there are no accepted or rejected papers. 

select c.conference_id , c.acronym, count(case when p.status = 'accepted' then p.paper_id end) as accepted, count(case when p.status = 'rejected' then p.paper_id end) as rejected,
						round((100.0 * count(case when p.status = 'accepted' then p.paper_id end) / 
						nullif((count(case when p.status = 'accepted' then p.paper_id end) + 
								count(case when p.status = 'rejected' then p.paper_id end)), 0)), 2) as acceptance_rate
from conference c 
left join track t 
on c.conference_id = t.conference_id 
left join paper p 
on p.track_id  = t.track_id
group by c.conference_id;