--For every conference, report its ID and acronym, total number of papers, number of accepted 
--papers, and average overall score across all completed reviews of its papers. Include 
--conferences with no papers, reporting zero paper counts and a NULL average. Each review 
--contributes once to the average; papers with multiple reviews must not inflate the paper counts.

select c.conference_id, c.acronym, count(distinct p.paper_id) as total_papers, count(distinct case when p.status = 'accepted' then p.paper_id end) as accepted_papers, avg(r.overall_score) as avg_score
from conference c 
left join track t 
on c.conference_id = t.conference_id 
left join paper p 
on t.track_id = p.track_id 
left join review r 
on p.paper_id = r.paper_id 
group by c.conference_id;