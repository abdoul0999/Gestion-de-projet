FROM python:3.11-slim
WORKDIR /app
COPY build/web .
CMD sh -c "python -m http.server ${PORT:-8080} --bind 0.0.0.0"
