INSERT INTO app_user (user_id, given_name, surname, email, affiliation, country, phone_number)
OVERRIDING SYSTEM VALUE VALUES
(1, 'Arman', 'Armanov', 'arman.armanov@example.com', 'NU', 'Kazakhstan', '+77010000000'),
(2, 'Amina', 'Aminova', 'amina.aminova@example.com', 'KBTU', 'Kazakhstan', '+77020000000'),
(3, 'John', 'Doe', 'john@example.com', 'MIT', 'USA', '+123456789'),
(4, 'Jane', 'Smith', 'jane@example.com', 'Stanford', 'USA', '+198765432'),
(5, 'Alan', 'Turing', 'alan@example.com', 'Cambridge', 'UK', '+44111111111'),
(6, 'Grace', 'Hopper', 'grace@example.com', 'Navy', 'USA', '+1555555555'),
(7, 'Linus', 'Torvalds', 'linus@example.com', 'Linux Found', 'USA', '+1666666666'),
(8, 'Ada', 'Lovelace', 'ada@example.com', 'London Univ', 'UK', '+44222222222'),
(9, 'Tim', 'Berners-Lee', 'tim@example.com', 'CERN', 'Switzerland', '+41000000000'),
(10, 'Bjarne', 'Stroustrup', 'bjarne@example.com', 'Morgan Stanley', 'USA', '+1777777777'),
(11, 'Reviewer', 'Only', 'revonly@example.com', 'Test Uni', 'UK', '+44333333333'),
(12, 'Author', 'Only', 'authonly@example.com', 'Test Uni 2', 'Canada', '+1888888888');

INSERT INTO author (author_id, orcid) VALUES
(1, '0000-1111'), (2, '0000-2222'), (3, NULL), (4, NULL), (12, NULL);

INSERT INTO reviewer (reviewer_id, years_experience) VALUES
(3, 5), (4, 2), (5, 10), (6, 4), (11, 1);

INSERT INTO reviewer_expertise (reviewer_id, area_label) VALUES
(3, 'Databases'), (4, 'Machine Learning'), (5, 'Algorithms');

INSERT INTO conference (conference_id, name, acronym, description, city, country, start_date, end_date, submission_deadline, review_deadline) 
OVERRIDING SYSTEM VALUE VALUES
(1, 'Astana Tech', 'AST26', 'Tech Conf', 'Astana', 'Kazakhstan', '2027-05-01', '2027-05-05', '2027-03-01', '2027-04-01'),
(2, 'Almaty IT', 'ALM26', 'IT Conf', 'Almaty', 'Kazakhstan', '2027-06-01', '2027-06-05', '2027-04-01', '2027-05-01'),
(3, 'London Data', 'LND26', 'Data Conf', 'London', 'UK', '2027-07-01', '2027-07-05', '2027-05-01', '2027-06-01');

INSERT INTO conference_reviewer (conference_id, reviewer_id) VALUES
(1, 3), (1, 4), (1, 5), (1, 6), (1, 11),
(2, 3), (2, 4), (2, 6);

INSERT INTO track (track_id, conference_id, name, description, research_area, coordinator_id) 
OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'AI Track', 'AI stuff', 'AI', 3),
(2, 1, 'Empty Track', 'No papers here', 'Networking', 4),
(3, 2, 'DB Track', 'Databases', 'Databases', 3);

INSERT INTO conference_session (session_id, conference_id, title, session_date, start_time, end_time, room_label, chair_id) 
OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'Astana Empty Session', '2027-05-02', '10:00:00', '12:00:00', 'Room A', 3),
(2, 1, 'Astana AI Session', '2027-05-02', '14:00:00', '16:00:00', 'Room B', 4),
(3, 2, 'Almaty DB Session', '2027-06-02', '10:00:00', '12:00:00', 'Room C', 3);

INSERT INTO paper (paper_id, track_id, title, abstract, submission_date, status, session_id) 
OVERRIDING SYSTEM VALUE VALUES
(1, 1, 'AI in 2026', 'Abstract here', '2027-02-15', 'accepted', 2),
(2, 3, 'ML basics', 'Introduction to mAcHiNe LeArNiNg in DBs.', '2027-03-10', 'accepted', 3),
(3, 1, 'No Session Paper', 'Abstract', '2027-02-16', 'accepted', NULL), 
(4, 1, 'Bad Paper 1', 'Will be withdrawn', '2027-02-20', 'withdrawn', NULL),
(5, 3, 'Bad Paper 2', 'Also withdrawn', '2027-03-15', 'withdrawn', NULL),
(6, 1, 'Rejected AI', 'Not good enough', '2027-02-25', 'rejected', NULL),
(7, 3, 'Rejected DB', 'Too slow', '2027-03-20', 'rejected', NULL),
(8, 1, 'Under Review AI', 'Still waiting', '2027-02-28', 'under review', NULL),
(9, 3, 'Just Submitted', 'Fresh paper', '2027-03-30', 'submitted', NULL),
(10, 1, 'Another ML paper', 'Uses machine learning for stuff', '2027-02-10', 'accepted', NULL);

INSERT INTO paper_author (paper_id, author_id, author_position, is_corresponding) VALUES
(1, 1, 1, TRUE), (1, 3, 2, FALSE),
(2, 4, 1, TRUE),
(3, 12, 1, TRUE),
(4, 2, 1, TRUE), 
(5, 2, 1, TRUE), 
(6, 1, 1, TRUE),
(7, 4, 1, TRUE),
(8, 3, 1, TRUE),
(9, 12, 1, TRUE),
(10, 1, 1, TRUE);

INSERT INTO paper_version (paper_id, version_no, file_location, uploaded_at, change_note) VALUES
(1, 1, '/files/1_v1.pdf', '2027-02-15 10:00:00', 'Initial'),
(1, 2, '/files/1_v2.pdf', '2027-02-18 10:00:00', 'Fixes'),
(1, 3, '/files/1_v3.pdf', '2027-02-20 10:00:00', 'Final'),
(2, 1, '/files/2_v1.pdf', '2027-03-10 10:00:00', NULL),
(3, 1, '/files/3_v1.pdf', '2027-02-16 10:00:00', NULL),
(4, 1, '/files/4_v1.pdf', '2027-02-20 10:00:00', NULL),
(5, 1, '/files/5_v1.pdf', '2027-03-15 10:00:00', NULL),
(6, 1, '/files/6_v1.pdf', '2027-02-25 10:00:00', NULL),
(7, 1, '/files/7_v1.pdf', '2027-03-20 10:00:00', NULL),
(8, 1, '/files/8_v1.pdf', '2027-02-28 10:00:00', NULL),
(9, 1, '/files/9_v1.pdf', '2027-03-30 10:00:00', NULL),
(10, 1, '/files/10_v1.pdf', '2027-02-10 10:00:00', NULL);

INSERT INTO review (review_id, paper_id, reviewer_id, overall_score, recommendation, comments_for_authors, review_submission_date) 
OVERRIDING SYSTEM VALUE VALUES
(1, 1, 3, 5, 'accept', 'Great', '2027-03-10'),
(2, 1, 4, 4, 'accept', 'Good', '2027-03-11'),
(3, 2, 3, 4, 'accept', 'Nice', '2027-04-10'),
(4, 3, 6, 5, 'accept', 'Perfect', '2027-03-10'),
(5, 6, 3, 2, 'reject', 'Bad', '2027-03-12'),
(6, 6, 4, 1, 'reject', 'Terrible', '2027-03-13'),
(7, 7, 6, 2, 'reject', 'No', '2027-04-12'),
(8, 8, 3, 3, 'reject', 'Hmm', '2027-03-15'),
(9, 10, 4, 4, 'accept', 'Ok', '2027-03-10'),
(10, 10, 6, 5, 'accept', 'Yes', '2027-03-11');

-- if column is IDENTITY then update its autoincrement because of test data
-- COALESCE needed if tables are empty

SELECT setval(pg_get_serial_sequence('app_user', 'user_id'), COALESCE((SELECT MAX(user_id) FROM app_user), 1));
SELECT setval(pg_get_serial_sequence('conference', 'conference_id'), COALESCE((SELECT MAX(conference_id) FROM conference), 1));
SELECT setval(pg_get_serial_sequence('track', 'track_id'), COALESCE((SELECT MAX(track_id) FROM track), 1));
SELECT setval(pg_get_serial_sequence('conference_session', 'session_id'), COALESCE((SELECT MAX(session_id) FROM conference_session), 1));
SELECT setval(pg_get_serial_sequence('paper', 'paper_id'), COALESCE((SELECT MAX(paper_id) FROM paper), 1));
SELECT setval(pg_get_serial_sequence('review', 'review_id'), COALESCE((SELECT MAX(review_id) FROM review), 1));