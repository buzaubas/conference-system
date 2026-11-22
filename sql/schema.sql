DROP TABLE IF EXISTS app_user CASCADE;
DROP TABLE IF EXISTS author CASCADE;
DROP TABLE IF EXISTS author_research_area CASCADE;
DROP TABLE IF EXISTS reviewer CASCADE;
DROP TABLE IF EXISTS reviewer_expertise CASCADE;
DROP TABLE IF EXISTS conference CASCADE;
DROP TABLE IF EXISTS conference_host CASCADE;
DROP TABLE IF EXISTS conference_reviewer CASCADE;
DROP TABLE IF EXISTS track CASCADE;
DROP TABLE IF EXISTS conference_session CASCADE;
DROP TABLE IF EXISTS paper CASCADE;
DROP TABLE IF EXISTS paper_keyword CASCADE;
DROP TABLE IF EXISTS paper_author CASCADE;
DROP TABLE IF EXISTS paper_version CASCADE;
DROP TABLE IF EXISTS review CASCADE;

-- 1. APP_USER
CREATE TABLE APP_USER (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    given_name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    affiliation VARCHAR(255) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone_number VARCHAR(50) NOT NULL
);

-- 2. AUTHOR
CREATE TABLE AUTHOR (
    author_id INT PRIMARY KEY REFERENCES APP_USER(user_id) ON DELETE CASCADE,
    orcid VARCHAR(20) -- optional
);

-- 3. AUTHOR_RESEARCH_AREA
CREATE TABLE AUTHOR_RESEARCH_AREA (
    author_id INT REFERENCES AUTHOR(author_id) ON DELETE CASCADE,
    area_label VARCHAR(100) NOT NULL,
    PRIMARY KEY (author_id, area_label)
);

-- 4. REVIEWER
CREATE TABLE REVIEWER (
    reviewer_id INT PRIMARY KEY REFERENCES APP_USER(user_id) ON DELETE CASCADE,
    years_experience INT NOT NULL CHECK (years_experience >= 0)
);

-- 5. REVIEWER_EXPERTISE
CREATE TABLE REVIEWER_EXPERTISE (
    reviewer_id INT REFERENCES REVIEWER(reviewer_id) ON DELETE CASCADE,
    area_label VARCHAR(100) NOT NULL,
    PRIMARY KEY (reviewer_id, area_label)
);

-- 6. CONFERENCE
CREATE TABLE CONFERENCE (
    conference_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    acronym VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    submission_deadline DATE NOT NULL,
    review_deadline DATE NOT NULL,
    CHECK (end_date >= start_date)
);

-- 7. CONFERENCE_HOST
CREATE TABLE CONFERENCE_HOST (
    conference_id INT REFERENCES CONFERENCE(conference_id) ON DELETE CASCADE,
    host_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (conference_id, host_name)
);

-- 8. CONFERENCE_REVIEWER
CREATE TABLE CONFERENCE_REVIEWER (
    conference_id INT REFERENCES CONFERENCE(conference_id) ON DELETE CASCADE,
    reviewer_id INT REFERENCES REVIEWER(reviewer_id) ON DELETE CASCADE,
    PRIMARY KEY (conference_id, reviewer_id)
);

-- 9. TRACK
CREATE TABLE TRACK (
    track_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conference_id INT NOT NULL REFERENCES CONFERENCE(conference_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    research_area VARCHAR(100) NOT NULL,
    coordinator_id INT NOT NULL REFERENCES REVIEWER(reviewer_id)
);

-- 10. CONFERENCE_SESSION
CREATE TABLE CONFERENCE_SESSION (
    session_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    conference_id INT NOT NULL REFERENCES CONFERENCE(conference_id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room_label VARCHAR(100) NOT NULL,
    chair_id INT NOT NULL REFERENCES REVIEWER(reviewer_id),
    CHECK (end_time > start_time)
);

-- 11. PAPER
CREATE TABLE PAPER (
    paper_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    track_id INT NOT NULL REFERENCES TRACK(track_id),
    title VARCHAR(255) NOT NULL,
    abstract TEXT NOT NULL,
    submission_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('submitted', 'under review', 'accepted', 'rejected', 'withdrawn')),
    session_id INT REFERENCES CONFERENCE_SESSION(session_id) ON DELETE SET NULL
);

-- 12. PAPER_KEYWORD
CREATE TABLE PAPER_KEYWORD (
    paper_id INT REFERENCES PAPER(paper_id) ON DELETE CASCADE,
    keyword VARCHAR(100) NOT NULL,
    PRIMARY KEY (paper_id, keyword)
);

-- 13. PAPER_AUTHOR
CREATE TABLE PAPER_AUTHOR (
    paper_id INT REFERENCES PAPER(paper_id) ON DELETE CASCADE,
    author_id INT REFERENCES AUTHOR(author_id) ON DELETE CASCADE,
    author_position INT NOT NULL CHECK (author_position > 0),
    is_corresponding BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (paper_id, author_id),
    UNIQUE (paper_id, author_position)
);

-- 14. PAPER_VERSION
CREATE TABLE PAPER_VERSION (
    paper_id INT REFERENCES PAPER(paper_id) ON DELETE CASCADE,
    version_no INT NOT NULL CHECK (version_no > 0),
    file_location VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL,
    change_note TEXT, -- optional
    PRIMARY KEY (paper_id, version_no)
);

-- 15. REVIEW
CREATE TABLE REVIEW (
    review_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    paper_id INT NOT NULL REFERENCES PAPER(paper_id) ON DELETE CASCADE,
    reviewer_id INT NOT NULL REFERENCES REVIEWER(reviewer_id),
    overall_score INT NOT NULL CHECK (overall_score BETWEEN 1 AND 5),
    recommendation VARCHAR(10) NOT NULL CHECK (recommendation IN ('accept', 'reject')),
    comments_for_authors TEXT NOT NULL,
    confidential_comments TEXT, -- optional
    review_submission_date DATE NOT NULL,
    UNIQUE (paper_id, reviewer_id)
);