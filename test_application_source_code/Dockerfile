# syntax=docker/dockerfile:1
FROM python:3.8.13-slim
WORKDIR /app
RUN pip install Flask

COPY . .

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]# syntax=docker/dockerfile:1
FROM python:3.8.13-slim
WORKDIR /app
RUN pip install Flask

COPY . .

CMD ["python", "-m", "flask", "run", "--host=0.0.0.0"]
