-- For every track, report its ID, name, conference ID, number of distinct papers, and number of 
-- distinct authors of those papers. Include tracks with no papers, reporting zero for both counts. A 
-- person who authored several papers in one track counts once for that track. 

select t.track_id, t."name", t.conference_id, count(distinct p.paper_id) as distinct_papers, count(distinct pa.author_id ) as distinct_authors
from track t 
left join paper p
on t.track_id = p.track_id 
left join paper_author pa 
on p.paper_id = pa.paper_id 
group by t.track_id;