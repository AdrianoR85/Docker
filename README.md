# Docker

## Apresentação

O **Docker** é uma plataforma que permite criar, distribuir e rodar aplicações dentro de **containers**. Containers são como pequenas máquinas virtuais leves, que isolam a aplicação e todas suas dependências.

### Por que usar Docker?

- Evita conflitos de versão entre softwares.
- Permite recriar ambientes rapidamente.
- Facilita o compartilhamento do ambiente com outros desenvolvedores.
- Ideal para estudo e produção de bancos de dados como o PostgreSQL.

---

## Menu

- [1. Como instalar o Docker no Linux](#1-como-instalar-o-docker-no-linux)
- [2. Principais comandos do Docker](#2-principais-comandos-do-docker)
- [3. Usando o Postgres no Docker](#3-usando-o-postgres-no-docker)
- [4. Como restaurar arquivos de backup](#4-como-restaurar-arquivos-de-backup)
- [5. Como criar alias para facilitar o acesso](#5-como-criar-alias-para-facilitar-o-acesso)

---

## 1. Como instalar o Docker no Linux

No Linux (Ubuntu/Debian), siga os passos básicos:

```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER  # permite rodar Docker sem sudo
```

Teste a instalação:

```bash
docker --version
docker compose version
```

---

## 2. Principais comandos do Docker

| Comando | Descrição |
|---------|-----------|
| `docker ps` | Lista containers ativos |
| `docker ps -a` | Lista todos os containers |
| `docker images` | Lista imagens baixadas |
| `docker volume ls` | Lista volumes do Docker |
| `docker stop <container>` | Para um container |
| `docker start <container>` | Inicia um container parado |
| `docker rm <container>` | Remove um container |
| `docker rmi <imagem>` | Remove uma imagem |
| `docker compose up -d` | Sobe os serviços definidos no docker-compose no modo destacado |
| `docker compose down` | Para os serviços e remove containers/volumes (com `-v`) |

---

## 3. Usando o Postgres no Docker

### Conceitos importantes

- **Image**: “Modelo” do container, com sistema e software pronto para rodar.
- **Container**: Instância de uma image em execução.
- **Dockerfile**: Arquivo que descreve como construir uma image personalizada.
- **Docker Compose**: Arquivo YAML que define múltiplos serviços, redes e volumes para um ambiente completo.

### Criando um Dockerfile para Postgres com locale

```dockerfile
FROM postgres:18.1

RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/pt_BR.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen pt_BR.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8
```

### Criando o `docker-compose.yml`

```yaml
services:
  postgres:
    build: .
    image: postgres:18.1
    container_name: postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PW}
    ports:
      - "5432:5432"
    volumes:
      - pg-server:/var/lib/postgresql

  pgadmin:
    image: dpage/pgadmin4
    container_name: pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD}
    ports:
      - "8080:80"
    depends_on:
      - postgres
    volumes:
      - pgadmin-data:/var/lib/pgadmin

volumes:
  pg-server:
  pgadmin-data:
```

### Variáveis de ambiente (`.env`)

```env
POSTGRES_USER=usuario
POSTGRES_PW=senha
PGADMIN_EMAIL=admin@local.com
PGADMIN_PASSWORD=senha_pgadmin
```

> O `.env` deve ficar na mesma pasta do `docker-compose.yml`.

### Rodando os containers

```bash
docker compose up -d
```

- PostgreSQL: `localhost:5432`
- pgAdmin: `http://localhost:8080`

No pgAdmin, registre o servidor:
- Host: `postgres`
- Port: `5432`
- User: `${POSTGRES_USER}`
- Password: `${POSTGRES_PW}`

---

## 4. Como restaurar arquivos de backup

1. Copie o arquivo de backup para dentro do container (opcional):

```bash
docker cp /caminho/do/backup.sql postgres:/backup.sql
```

2. Acesse o container com `psql`:

```bash
docker exec -it postgres psql -U usuario -d postgres
```

3. Rode o restore:

```sql
\i /backup.sql
```

> Atenção: se o dump alterar senhas ou criar usuários, pode sobrescrever os já configurados.

---

## 5. Como criar alias para facilitar o acesso

### Alias para psql dentro do container

```bash
alias pg-cli="docker exec -it postgres psql -U usuario"
```

### Alias para abrir pgAdmin

```bash
alias pg-open="xdg-open http://localhost:8080"  # Linux
# alias pg-open="open http://localhost:8080"    # macOS
```

### Alias para gerenciar containers

| Alias      | Comando real                                    | Função |
|------------|-----------------------------------------------|--------|
| `pg-up`    | `docker compose up -d` + abre pgAdmin         | Inicia containers e abre pgAdmin |
| `pg-stop`  | `docker compose stop`                          | Para containers sem apagar volumes |
| `pg-start` | `docker compose start`                         | Liga containers parados |
| `pg-down`  | `docker compose down -v`                       | Para e remove containers/volumes |
| `pg-cli`   | `docker exec -it postgres psql -U usuario`    | Abre terminal direto no psql |

> Dica: crie scripts `.sh` com esses comandos e adicione aliases no `~/.bashrc` ou `~/.zshrc`.

---

### 🎯 Resultado final

- Ambiente Docker com PostgreSQL e pgAdmin funcionando
- Banco de dados pronto para uso
- Restore de backups configurado
- Alias e scripts para start, stop, up, down e acesso rápido ao psql
- Ambiente portátil e fácil de recriar

