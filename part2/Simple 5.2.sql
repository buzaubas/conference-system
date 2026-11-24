select p.paper_id, p.title 
from paper p 
where p.abstract ilike '%machine learning%';