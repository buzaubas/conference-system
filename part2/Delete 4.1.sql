	begin;
	delete from paper 
	where paper_id in (select p.paper_id from 
									paper p join paper_author pa 
									on p.paper_id = pa.paper_id 
									join author a 
									on a.author_id = pa.author_id 
									join app_user au 
									on au.user_id = a.author_id 
									where au.email = 'amina.aminova@example.com' 
													and pa.is_corresponding = true
													and p.status = 'withdrawn');
	commit;
