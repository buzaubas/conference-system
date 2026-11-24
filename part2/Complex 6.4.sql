--Find reviewers whose number of completed reviews is greater than the average number of 
--completed reviews per reviewer across the entire database. Include reviewers with zero reviews 
--when computing that average. Show each matching reviewer’s ID, full name, review count, and 
--the overall average. Use aggregation and a nested query or common table expression. 


select r.reviewer_id, au.given_name, au.surname, count(rv.review_id) as review_count, (select avg(t.review_count) as overall_avg from (
									select r.reviewer_id, count(rv.review_id ) as review_count
									from reviewer r
									left join review rv
									on r.reviewer_id = rv.reviewer_id 
									group by r.reviewer_id) as t)
from reviewer r
join app_user au 
on r.reviewer_id = au.user_id 
left join review rv
on r.reviewer_id = rv.reviewer_id 
group by r.reviewer_id, au.given_name, au.surname
having count(rv.review_id) > (select avg(t.review_count) as overall_avg from (
									select r.reviewer_id, count(rv.review_id ) as review_count
									from reviewer r
									left join review rv
									on r.reviewer_id = rv.reviewer_id 
									group by r.reviewer_id) as t);

