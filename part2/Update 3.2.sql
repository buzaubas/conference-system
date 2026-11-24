update conference c 
set review_deadline = 
case
	when c.city = 'Astana'then review_deadline + interval '7 days'
	else review_deadline + interval '3 days'
end

