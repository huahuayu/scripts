docker run -d --name postgres --restart always -e POSTGRES_USER=root -e POSTGRES_PASSWORD=root -p 5432:5432 -v /data/postgres:/var/lib/postgresql/data postgres
