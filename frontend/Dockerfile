FROM python:3.11-slim
WORKDIR /app
COPY build/web .
CMD python -m http.server $PORT
