#!/bin/sh 

sleep 5 
mongoimport --db $MONGO_INITDB_DATABASE --collection protocolDriverInstances --type json --file /docker-entrypoint-initdb.d/data/protocolDriverInstances.json 
mongoimport --db $MONGO_INITDB_DATABASE --collection protocolConnections --type json --file /docker-entrypoint-initdb.d/data/protocolConnections.json 
mongoimport --db $MONGO_INITDB_DATABASE --collection realtimeData --type json --file /docker-entrypoint-initdb.d/data/realtimeData.json 
mongoimport --db $MONGO_INITDB_DATABASE --collection processInstances --type json --file /docker-entrypoint-initdb.d/data/processInstances.json 
mongoimport --db $MONGO_INITDB_DATABASE --collection users --type json --file /docker-entrypoint-initdb.d/data/users.json 
mongoimport --db $MONGO_INITDB_DATABASE --collection roles --type json --file /docker-entrypoint-initdb.d/data/roles.json 
