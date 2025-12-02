#!/bin/bash
# Liga os containers parados
docker compose start
echo "Containers iniciados!"
echo "Para acessar pgAdmin: http://localhost:8080"
echo "Para acessar psql: use 'pg-cli'"
