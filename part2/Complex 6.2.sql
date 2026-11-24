--For every reviewer, report their ID, full name, number of completed reviews, and average overall 
--score across those reviews. Include reviewers with no reviews, reporting a count of zero and a 
--NULL average. 

select r.reviewer_id, au.given_name, au.surname, count(rv.review_id) as completed_reviews, avg(rv.overall_score) as average_score
from reviewer r 
left join app_user au 
on r.reviewer_id = au.user_id 
left join review rv
on r.reviewer_id = rv.reviewer_id 
group by r.reviewer_id, au.given_name, au.surname;