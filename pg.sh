#!/bin/bash

# Script helper para PostgreSQL + pgAdmin

# Inicia os containers
docker compose up -d

# Espera alguns segundos para o Postgres subir
echo "Aguardando 5 segundos para o Postgres iniciar..."
sleep 5

# Abre o pgAdmin no navegador
xdg-open http://localhost:8080 || open http://localhost:8080

# Mensagem final
echo "Containers estão ativos. pgAdmin aberto no navegador!"
echo "Para acessar psql: docker exec -it postgres psql -U adriano"

