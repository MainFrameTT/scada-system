FROM python:3.11-slim

WORKDIR /app

# Установка зависимостей системы
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-dev \
    && rm -rf /var/lib/apt/lists/*

# Копирование requirements и установка Python зависимостей
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копирование кода приложения
COPY backend/ .

# Создание статических файлов
RUN python manage.py collectstatic --noinput

# Порт приложения
EXPOSE 8000

# Запуск приложения
CMD ["gunicorn", "scada_backend.wsgi:application", "--bind", "0.0.0.0:8000"]