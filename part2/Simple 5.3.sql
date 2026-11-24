select pv.paper_id , pv.version_no, pv.file_location, pv.uploaded_at
from paper_version pv 
where pv.paper_id = 1
order by pv.version_no desc;
