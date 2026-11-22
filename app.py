from flask import Flask, render_template, request, redirect, url_for, flash
from sqlalchemy import text
from requests import *

app = Flask(__name__)
app.secret_key = "csci341_secret_key"

# --- ДОБАВЛЕННЫЙ БЛОК: Инициализация базы данных при старте Flask ---
with app.app_context():
    try:
        # Проверяем, существует ли таблица app_user
        with engine.connect() as conn:
            conn.execute(text("SELECT 1 FROM app_user LIMIT 1"))
    except Exception:
        # Если получаем ошибку (таблицы нет), запускаем скрипты
        print("Таблицы не найдены. Запускаем schema.sql и seed.sql...")
        execute_sql_file("sql/schema.sql")
        execute_sql_file("sql/seed.sql")
# -------------------------------------------------------------------

@app.route("/")
def dashboard():
    return render_template("dashboard.html")

@app.route("/users", methods=["GET", "POST"])
def manage_users():
    if request.method == "POST":
        given_name = request.form.get("given_name")
        surname = request.form.get("surname")
        email = request.form.get("email")
        affiliation = request.form.get("affiliation")
        country = request.form.get("country")
        phone_number = request.form.get("phone_number")

        add_user(given_name, surname, email, affiliation, country, phone_number)
        return redirect(url_for("manage_users"))

    users = get_all_users()
    return render_template("users.html", users=users)

@app.route("/edit/<int:user_id>", methods=["GET", "POST"])
def edit_user(user_id):
    if request.method == "POST":
        given_name = request.form.get("given_name")
        surname = request.form.get("surname")
        email = request.form.get("email")
        affiliation = request.form.get("affiliation")
        country = request.form.get("country")
        phone_number = request.form.get("phone_number")

        update_user(user_id, given_name, surname, email, affiliation, country, phone_number)
        return redirect(url_for("manage_users"))

    user = get_user_by_id(user_id)
    return render_template("edit_user.html", user=user)

@app.route("/delete/<int:user_id>", methods=["POST"])
def delete_user_route(user_id):
    delete_user(user_id)
    return redirect(url_for("manage_users"))

@app.route("/papers", methods=["GET", "POST"])
def manage_papers():
    if request.method == "POST":
        track_id = request.form.get("track_id")
        title = request.form.get("title")
        abstract = request.form.get("abstract")
        submission_date = request.form.get("submission_date")
        status = request.form.get("status")

        add_paper(track_id, title, abstract, submission_date, status)
        return redirect(url_for("manage_papers"))

    papers = get_all_papers()
    return render_template("papers.html", papers=papers)

@app.route("/edit_paper/<int:paper_id>", methods=["GET", "POST"])
def edit_paper(paper_id):
    if request.method == "POST":
        title = request.form.get("title")
        abstract = request.form.get("abstract")
        status = request.form.get("status")

        update_paper(paper_id, title, abstract, status)
        # После сохранения остаемся на этой же странице
        return redirect(url_for("edit_paper", paper_id=paper_id))

    paper = get_paper_by_id(paper_id)
    authors = get_paper_authors(paper_id)
    versions = get_paper_versions(paper_id)
    all_users = get_all_users() # Для выпадающего списка выбора автора

    return render_template(
        "edit_paper.html",
        paper=paper, authors=authors, versions=versions, all_users=all_users
    )

@app.route("/paper/<int:paper_id>/add_author", methods=["POST"])
def add_author_route(paper_id):
    author_id = request.form.get("author_id")
    author_position = request.form.get("author_position")
    is_corresponding = True if request.form.get("is_corresponding") else False

    try:
        add_paper_author(paper_id, author_id, author_position, is_corresponding)
    except Exception as e:
        print(f"Error adding author: {e}") # В идеале здесь использовать flash()

    return redirect(url_for("edit_paper", paper_id=paper_id))

@app.route("/paper/<int:paper_id>/add_version", methods=["POST"])
def add_version_route(paper_id):
    version_no = request.form.get("version_no")
    file_location = request.form.get("file_location")

    try:
        add_paper_version(paper_id, version_no, file_location)
    except Exception as e:
        print(f"Error adding version: {e}")

    return redirect(url_for("edit_paper", paper_id=paper_id))

@app.route("/delete_paper/<int:paper_id>", methods=["POST"])
def delete_paper_route(paper_id):
    delete_paper(paper_id)
    return redirect(url_for("manage_papers"))

# --- КЛЮЧЕВЫЕ СЛОВА И УДАЛЕНИЕ ДЛЯ СТАТЕЙ ---
@app.route("/paper/<int:paper_id>/add_keyword", methods=["POST"])
def add_keyword_route(paper_id):
    keyword = request.form.get("keyword")
    try:
        add_paper_keyword(paper_id, keyword)
        flash("Keyword added.", "success")
    except Exception as e:
        flash(f"Error adding keyword: {e}", "error")
    return redirect(url_for("edit_paper", paper_id=paper_id))

@app.route("/paper/<int:paper_id>/delete_keyword/<keyword>", methods=["POST"])
def delete_keyword_route(paper_id, keyword):
    delete_paper_keyword(paper_id, keyword)
    flash("Keyword deleted.", "success")
    return redirect(url_for("edit_paper", paper_id=paper_id))

@app.route("/paper/<int:paper_id>/delete_author/<int:author_id>", methods=["POST"])
def delete_author_route(paper_id, author_id):
    delete_paper_author(paper_id, author_id)
    flash("Author removed from paper.", "success")
    return redirect(url_for("edit_paper", paper_id=paper_id))

@app.route("/paper/<int:paper_id>/delete_version/<int:version_no>", methods=["POST"])
def delete_version_route(paper_id, version_no):
    delete_paper_version(paper_id, version_no)
    flash("Version deleted.", "success")
    return redirect(url_for("edit_paper", paper_id=paper_id))

# --- РЕЦЕНЗИИ (REVIEWS) ---
@app.route("/reviews", methods=["GET", "POST"])
def manage_reviews():
    if request.method == "POST":
        paper_id = request.form.get("paper_id")
        reviewer_id = request.form.get("reviewer_id")
        overall_score = request.form.get("overall_score")
        recommendation = request.form.get("recommendation")
        comments_for_authors = request.form.get("comments_for_authors")
        confidential_comments = request.form.get("confidential_comments")

        try:
            add_review(paper_id, reviewer_id, overall_score, recommendation, comments_for_authors, confidential_comments)
            flash("Review submitted successfully!", "success")
        except Exception as e:
            flash(f"Operation rejected: {e}", "error")
        return redirect(url_for("manage_reviews"))

    reviews = get_all_reviews()
    papers = get_all_papers()
    reviewers = get_all_reviewers()
    return render_template("reviews.html", reviews=reviews, papers=papers, reviewers=reviewers)

@app.route("/edit_review/<int:review_id>", methods=["GET", "POST"])
def edit_review(review_id):
    if request.method == "POST":
        overall_score = request.form.get("overall_score")
        recommendation = request.form.get("recommendation")
        comments_for_authors = request.form.get("comments_for_authors")
        confidential_comments = request.form.get("confidential_comments")

        try:
            update_review(review_id, overall_score, recommendation, comments_for_authors, confidential_comments)
            flash("Review updated!", "success")
        except Exception as e:
            flash(f"Error updating review: {e}", "error")
        return redirect(url_for("manage_reviews"))

    review = get_review_by_id(review_id)
    return render_template("edit_review.html", review=review)

@app.route("/delete_review/<int:review_id>", methods=["POST"])
def delete_review_route(review_id):
    delete_review(review_id)
    flash("Review deleted.", "success")
    return redirect(url_for("manage_reviews"))

@app.route('/sessions', methods=['GET', 'POST'])
def sessions():
    if request.method == 'POST':
        paper_id = request.form.get('paper_id')
        session_id = request.form.get('session_id')

        if not paper_id or not session_id:
            flash("Выберите статью и сессию!", "danger")
            return redirect(url_for('sessions'))

        try:
            # Пытаемся назначить статью на сессию (сработают бизнес-правила из requests.py)
            assign_paper_to_session(int(paper_id), int(session_id))
            flash("Статья успешно добавлена в сессию!", "success")
        except ValueError as e:
            # Если бизнес-правило нарушено (статус не accepted или разные конференции)
            flash(f"Ошибка назначения: {str(e)}", "danger")
        except Exception as e:
            flash(f"Системная ошибка: {str(e)}", "danger")

        return redirect(url_for('sessions'))

    # --- Обработка GET-запроса (открытие страницы) ---

    # 1. Получаем все сессии
    sessions_list = get_all_sessions()

    # 2. Получаем уже назначенные статьи
    presentations_list = get_presentations()

    # 3. Получаем доступные статьи для выпадающего списка (только accepted и без сессии)
    all_papers = get_all_papers()
    available_papers = [
        p for p in all_papers
        if p['status'] == 'accepted' and p.get('session_id') is None
    ]

    return render_template(
        'sessions.html',
        sessions=sessions_list,
        presentations=presentations_list,
        available_papers=available_papers
    )
