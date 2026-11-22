FROM python:3.10-slim

WORKDIR /app

# Копируем зависимости и устанавливаем их
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем все файлы из текущей корневой папки в /app
COPY . .

# Команда для запуска Flask
CMD ["flask", "run", "--host=0.0.0.0"]