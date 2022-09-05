docker run -d --name mongodb --restart=always -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=passwd -p 27017:27017 -v /data/mongo/data:/data/db mongo
