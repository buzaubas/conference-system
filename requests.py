import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from sqlalchemy.exc import SQLAlchemyError

# Получаем строку подключения из переменной окружения Docker
DATABASE_URL = os.getenv("DATABASE_URL")

# Создаем движок подключения к БД
engine = create_engine(DATABASE_URL, echo=True)

def execute_sql_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as file:
            sql_script = text(file.read())

        with engine.begin() as connection:
            connection.execute(sql_script)
            print(f"Успешно: {filepath}")

    except FileNotFoundError:
        print(f"Ошибка: Файл {filepath} не найден. Проверьте пути копирования в Dockerfile.")
    except SQLAlchemyError as e:
        print(f"Ошибка базы данных при выполнении {filepath}:")
        print(e)

if __name__ == "__main__":
    print("Начинаем создание и заполнение базы данных...")

    # 1. Запускаем файл создания схемы (Task 1)
    execute_sql_file("sql/schema.sql")

    # 2. Запускаем файл заполнения тестовыми данными (Task 2)
    execute_sql_file("sql/seed.sql")

    # 3. Выводим количество строк для проверки (Task 2)
    with engine.connect() as conn:
        result = conn.execute(text("SELECT COUNT(*) FROM app_user;"))
        print(f"Количество пользователей в БД: {result.fetchone()[0]}")

# Создаем фабрику сессий
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_all_users():
    """Получение всех пользователей для Read операции"""
    with SessionLocal() as session:
        # Используем mappings() для доступа к колонкам по имени в шаблоне
        result = session.execute(text("SELECT * FROM app_user ORDER BY user_id"))
        return result.mappings().all()

def add_user(given_name, surname, email, affiliation, country, phone_number):
    """Добавление нового пользователя (Create)"""
    with SessionLocal() as session:
        # Используем параметризованный запрос для защиты от SQL-инъекций
        sql = text("""
            INSERT INTO app_user (given_name, surname, email, affiliation, country, phone_number)
            VALUES (:given_name, :surname, :email, :affiliation, :country, :phone_number)
        """)
        session.execute(sql, {
            "given_name": given_name,
            "surname": surname,
            "email": email,
            "affiliation": affiliation,
            "country": country,
            "phone_number": phone_number
        })
        session.commit() # Фиксируем транзакцию

def get_user_by_id(user_id):
    """Получение одного пользователя для Update"""
    with SessionLocal() as session:
        sql = text("SELECT * FROM app_user WHERE user_id = :user_id")
        result = session.execute(sql, {"user_id": user_id})
        return result.mappings().first()

def update_user(user_id, given_name, surname, email, affiliation, country, phone_number):
    """Обновление пользователя (Update)"""
    with SessionLocal() as session:
        sql = text("""
            UPDATE app_user
            SET given_name = :given_name, surname = :surname, email = :email,
                affiliation = :affiliation, country = :country, phone_number = :phone_number
            WHERE user_id = :user_id
        """)
        session.execute(sql, {
            "given_name": given_name, "surname": surname, "email": email,
            "affiliation": affiliation, "country": country, "phone_number": phone_number,
            "user_id": user_id
        })
        session.commit()

def delete_user(user_id):
    """Удаление пользователя (Delete)"""
    with SessionLocal() as session:
        sql = text("DELETE FROM app_user WHERE user_id = :user_id")
        session.execute(sql, {"user_id": user_id})
        session.commit()

def get_all_papers():
    with SessionLocal() as session:
        sql = text("SELECT * FROM paper ORDER BY paper_id")
        result = session.execute(sql)
        return result.mappings().all()

def add_paper(track_id, title, abstract, submission_date, status):
    with SessionLocal() as session:
        sql = text("""
            INSERT INTO paper (track_id, title, abstract, submission_date, status)
            VALUES (:track_id, :title, :abstract, :submission_date, :status)
        """)
        session.execute(sql, {
            "track_id": track_id,
            "title": title,
            "abstract": abstract,
            "submission_date": submission_date,
            "status": status
        })
        session.commit()

def get_paper_by_id(paper_id):
    """Получение одной статьи для Update"""
    with SessionLocal() as session:
        sql = text("SELECT * FROM paper WHERE paper_id = :paper_id")
        result = session.execute(sql, {"paper_id": paper_id})
        return result.mappings().first()

def update_paper(paper_id, title, abstract, status):
    """Обновление статьи (Update)"""
    with SessionLocal() as session:
        sql = text("""
            UPDATE paper
            SET title = :title, abstract = :abstract, status = :status
            WHERE paper_id = :paper_id
        """)
        session.execute(sql, {
            "title": title, "abstract": abstract, "status": status, "paper_id": paper_id
        })
        session.commit()

def delete_paper(paper_id):
    """Удаление статьи (Delete)"""
    with SessionLocal() as session:
        sql = text("DELETE FROM paper WHERE paper_id = :paper_id")
        session.execute(sql, {"paper_id": paper_id})
        session.commit()

def get_paper_authors(paper_id):
    """Получение всех авторов конкретной статьи"""
    with SessionLocal() as session:
        sql = text("""
            SELECT pa.*, u.given_name, u.surname, u.email
            FROM paper_author pa
            JOIN app_user u ON pa.author_id = u.user_id
            WHERE pa.paper_id = :paper_id
            ORDER BY pa.author_position
        """)
        return session.execute(sql, {"paper_id": paper_id}).mappings().all()

def add_paper_author(paper_id, author_id, author_position, is_corresponding):
    with SessionLocal() as session:
        # Проверка: не оставлял ли этот пользователь уже рецензию на эту статью?
        has_reviewed = session.execute(
            text("SELECT 1 FROM review WHERE paper_id = :pid AND reviewer_id = :aid"),
            {"pid": paper_id, "aid": author_id}
        ).first()
        if has_reviewed:
            raise ValueError("Cannot add author: this user has already reviewed this paper.")

        res = session.execute(text("SELECT 1 FROM author WHERE author_id = :uid"), {"uid": author_id}).first()
        if not res:
            session.execute(text("INSERT INTO author (author_id) VALUES (:uid)"), {"uid": author_id})

        sql = text("""
            INSERT INTO paper_author (paper_id, author_id, author_position, is_corresponding)
            VALUES (:paper_id, :author_id, :author_position, :is_corresponding)
        """)
        session.execute(sql, {
            "paper_id": paper_id, "author_id": author_id,
            "author_position": author_position, "is_corresponding": is_corresponding
        })
        session.commit()

def get_paper_versions(paper_id):
    """Получение версий статьи"""
    with SessionLocal() as session:
        sql = text("SELECT * FROM paper_version WHERE paper_id = :paper_id ORDER BY version_no DESC")
        return session.execute(sql, {"paper_id": paper_id}).mappings().all()

def add_paper_version(paper_id, version_no, file_location):
    """Добавление новой версии статьи"""
    with SessionLocal() as session:
        sql = text("""
            INSERT INTO paper_version (paper_id, version_no, file_location, uploaded_at)
            VALUES (:paper_id, :version_no, :file_location, CURRENT_TIMESTAMP)
        """)
        session.execute(sql, {"paper_id": paper_id, "version_no": version_no, "file_location": file_location})
        session.commit()

# --- ДОПОЛНЕНИЯ ДЛЯ СТАТЕЙ (Ключевые слова и удаление) ---
def get_paper_keywords(paper_id):
    with SessionLocal() as session:
        sql = text("SELECT keyword FROM paper_keyword WHERE paper_id = :paper_id")
        return [row[0] for row in session.execute(sql, {"paper_id": paper_id}).all()]

def add_paper_keyword(paper_id, keyword):
    with SessionLocal() as session:
        sql = text("INSERT INTO paper_keyword (paper_id, keyword) VALUES (:paper_id, :keyword)")
        session.execute(sql, {"paper_id": paper_id, "keyword": keyword})
        session.commit()

def delete_paper_keyword(paper_id, keyword):
    with SessionLocal() as session:
        sql = text("DELETE FROM paper_keyword WHERE paper_id = :paper_id AND keyword = :keyword")
        session.execute(sql, {"paper_id": paper_id, "keyword": keyword})
        session.commit()

def delete_paper_author(paper_id, author_id):
    with SessionLocal() as session:
        sql = text("DELETE FROM paper_author WHERE paper_id = :paper_id AND author_id = :author_id")
        session.execute(sql, {"paper_id": paper_id, "author_id": author_id})
        session.commit()

def delete_paper_version(paper_id, version_no):
    with SessionLocal() as session:
        sql = text("DELETE FROM paper_version WHERE paper_id = :paper_id AND version_no = :version_no")
        session.execute(sql, {"paper_id": paper_id, "version_no": version_no})
        session.commit()

# --- CRUD ДЛЯ РЕЦЕНЗИЙ + БИЗНЕС-ПРАВИЛО 1 ---
def get_all_reviews():
    with SessionLocal() as session:
        sql = text("""
            SELECT r.*, p.title AS paper_title, u.given_name, u.surname
            FROM review r
            JOIN paper p ON r.paper_id = p.paper_id
            JOIN app_user u ON r.reviewer_id = u.user_id
            ORDER BY r.review_id
        """)
        return session.execute(sql).mappings().all()

def get_all_reviewers():
    with SessionLocal() as session:
        sql = text("""
            SELECT rev.reviewer_id, u.given_name, u.surname, u.email
            FROM reviewer rev
            JOIN app_user u ON rev.reviewer_id = u.user_id
            ORDER BY u.surname
        """)
        return session.execute(sql).mappings().all()

def add_review(paper_id, reviewer_id, overall_score, recommendation, comments_for_authors, confidential_comments):
    with SessionLocal() as session:
        # ПРОВЕРКА 1: Является ли рецензент автором этой статьи?
        check_sql = text("SELECT 1 FROM paper_author WHERE paper_id = :pid AND author_id = :rid")
        is_author = session.execute(check_sql, {"pid": paper_id, "rid": reviewer_id}).first()
        if is_author:
            raise ValueError("Self-review is prohibited: this reviewer is an author of the paper.")

        sql = text("""
            INSERT INTO review (paper_id, reviewer_id, overall_score, recommendation, comments_for_authors, confidential_comments, review_submission_date)
            VALUES (:pid, :rid, :score, :rec, :c_auth, :c_conf, CURRENT_DATE)
        """)
        session.execute(sql, {
            "pid": paper_id, "rid": reviewer_id, "score": overall_score,
            "rec": recommendation, "c_auth": comments_for_authors,
            "c_conf": confidential_comments if confidential_comments else None
        })
        session.commit()

def get_review_by_id(review_id):
    with SessionLocal() as session:
        sql = text("SELECT * FROM review WHERE review_id = :rid")
        return session.execute(sql, {"rid": review_id}).mappings().first()

def update_review(review_id, overall_score, recommendation, comments_for_authors, confidential_comments):
    with SessionLocal() as session:
        sql = text("""
            UPDATE review
            SET overall_score = :score, recommendation = :rec,
                comments_for_authors = :c_auth, confidential_comments = :c_conf
            WHERE review_id = :rid
        """)
        session.execute(sql, {
            "score": overall_score, "rec": recommendation, "c_auth": comments_for_authors,
            "c_conf": confidential_comments if confidential_comments else None, "rid": review_id
        })
        session.commit()

def delete_review(review_id):
    with SessionLocal() as session:
        sql = text("DELETE FROM review WHERE review_id = :rid")
        session.execute(sql, {"rid": review_id})
        session.commit()

# --- СЕССИИ И ПРЕЗЕНТАЦИИ (БИЗНЕС-ПРАВИЛО 2) ---
def get_all_sessions():
    with SessionLocal() as session:
        # Исправлено: таблица называется conference_session
        sql = text("SELECT * FROM conference_session ORDER BY session_id")
        return session.execute(sql).mappings().all()

def get_presentations():
    with SessionLocal() as session:
        # Исправлено: берем статьи, у которых заполнено поле session_id
        sql = text("""
            SELECT p.paper_id, p.session_id, p.title as paper_title, s.title as session_title
            FROM paper p
            JOIN conference_session s ON p.session_id = s.session_id
            WHERE p.session_id IS NOT NULL
        """)
        return session.execute(sql).mappings().all()

def assign_paper_to_session(paper_id, session_id):
    with SessionLocal() as db_session:
        # ПРОВЕРКА 1: Статус статьи должен быть 'accepted'
        paper_sql = text("SELECT status, track_id FROM paper WHERE paper_id = :pid")
        paper = db_session.execute(paper_sql, {"pid": paper_id}).mappings().first()

        if not paper:
            raise ValueError("Paper not found.")
        if paper['status'] != 'accepted':
            raise ValueError(f"Paper must be 'accepted'. Current status: '{paper['status']}'.")

        # ПРОВЕРКА 2: Трек статьи и Сессия должны относиться к одной конференции
        track_sql = text("SELECT conference_id FROM track WHERE track_id = :tid")
        track = db_session.execute(track_sql, {"tid": paper['track_id']}).mappings().first()

        # Исправлено: таблица conference_session
        session_sql = text("SELECT conference_id FROM conference_session WHERE session_id = :sid")
        sess = db_session.execute(session_sql, {"sid": session_id}).mappings().first()

        if track and sess and track['conference_id'] != sess['conference_id']:
            raise ValueError(
                f"Conference mismatch! Paper's track belongs to conference {track['conference_id']}, "
                f"but session belongs to conference {sess['conference_id']}."
            )

        # Исправлено: обновляем внешний ключ session_id в таблице paper
        update_sql = text("UPDATE paper SET session_id = :sid WHERE paper_id = :pid")
        db_session.execute(update_sql, {"pid": paper_id, "sid": session_id})
        db_session.commit()


